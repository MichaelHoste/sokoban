module MailingService
  # Automatic mailing (every 7 days unless the user was active less than 48hours ago)
  def self.delayed_send_mailing
    Delayed::Job.where(:queue => 'send_mailing').destroy_all
    MailingService.delay(:run_at => Time.now + 30.minutes, :queue => 'send_mailing').send_mailing(true)
  end

  def self.send_mailing(repeat = false)
    MailingService.sync_with_mapmimi

    MailingService.users_to_mail_now.each do |user|
      UserNotifier.delay.weekly_notification(user.id)
      UserNotifier.delay.weekly_notification(user.id, true)
      user.update_attributes!({ :next_mailing_at => Time.now + 7.days + rand(-12..12).hours })
    end

    if repeat
      MailingService.delayed_send_mailing
    end
  end

  def self.users_to_mail_now
    mail_users = User.registered.where(:mailing_unsubscribe => false)
                                .where('next_mailing_at < ?', Time.now)

    # Reject if not in the madmimi list
    mimi = MadMimi.new(ENV['MADMIMI_EMAIL'], ENV['MADMIMI_KEY'])
    mail_users = mail_users.keep_if do |user|
      lists = mimi.memberships(user.email)
      if lists['lists']
        lists = lists['lists']['list']
        if lists.is_a? Array
          lists.collect { |list| list['name'] }.include? ENV['MADMIMI_LIST']
        else
          lists['name'] == ENV['MADMIMI_LIST']
        end
      else
        false
      end
    end

    # Reject if user solved a level in the last 2 days.
    mail_users = mail_users.keep_if do |user|
      user.scores.where('created_at > ?', Time.now - 2.days).empty?
    end

    mail_users
  end

  def self.sync_with_mapmimi
    bdd_mails                = User.registered.where(:mailing_unsubscribe => false).collect(&:email)
    bdd_suppressed_mails     = User.registered.where(:mailing_unsubscribe => true).collect(&:email)
    mapmimi_mails            = MailingService.mapmimi_mails
    mapmimi_suppressed_mails = MailingService.mapmimi_suppressed_mails

    # if mail in bdd  and not in mapmimi, add it
    mails_to_add_to_mapmimi = bdd_mails - mapmimi_mails - mapmimi_suppressed_mails
    mails_to_add_to_mapmimi.each do |mail|
      user = User.where(:email => mail).first
      mimi = MadMimi.new(ENV['MADMIMI_EMAIL'], ENV['MADMIMI_KEY'])
      mimi.csv_import("email, first name, last name, full name, gender, locale\n" +
                      "#{user.email}, #{user.f_first_name}, #{user.f_last_name}, #{user.name}, #{user.gender}, #{user.locale}")
      mimi.add_to_list(user.email, ENV['MADMIMI_LIST'])
    end

    # if suppress mail in mapmimi and not in bdd, add it
    mails_to_unsubscribe_to_bdd = mapmimi_suppressed_mails - bdd_suppressed_mails
    mails_to_unsubscribe_to_bdd.each do |mail|
      User.where(:email => mail).try(:first).update_attributes!({ :mailing_unsubscribe => true })
    end
  end

  # Contain only not-suppressed users
  def self.mapmimi_mails
    users = []
    page = 1

    begin
      res = HTTParty.get("http://api.madmimi.com/audience_members.json",
        :query => { :api_key    => ENV['MADMIMI_KEY'],
                    :username   => ENV['MADMIMI_EMAIL'],
                    :per_page   => 100,
                    :page       => page })

      page = page + 1

      users = users + res['audience'].collect do |audience|
        if audience['lists'].include? ENV['MADMIMI_LIST']
          audience['columns']['email']
        else
          nil
        end
      end.compact
    end until res['audience'].empty?

    users
  end

  # Contain only suppressed users (unsubscribed or soft/hard-bounce)
  def self.mapmimi_suppressed_mails
    users = []
    page = 1

    begin
      res = HTTParty.get("http://api.madmimi.com/audience_members.json",
        :query => { :api_key         => ENV['MADMIMI_KEY'],
                    :username        => ENV['MADMIMI_EMAIL'],
                    :suppressed_only => true, # with suppressed users
                    :per_page        => 100,
                    :page            => page })

      page = page + 1

      users = users + res['audience'].collect do |audience|
        if audience['lists'].include? ENV['MADMIMI_LIST'] or audience['lists'].empty?
          audience['columns']['email']
        else
          nil
        end
      end.compact
    end until res['audience'].empty?

    users
  end
end

