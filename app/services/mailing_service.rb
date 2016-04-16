module MailingService
  TOO_SOON             = 2.days
  TIME_BEFORE_INACTIVE = 3.months
  JOB_DELAY            = 6.hours

  # Automatic mailing (every 7 days unless the user was active less than 48hours ago)
  def self.delayed_send_mailing
    Delayed::Job.where(:queue => 'send_mailing').destroy_all
    MailingService.delay(:run_at => Time.now + JOB_DELAY, :queue => 'send_mailing').send_mailing(true)
  end

  def self.send_mailing(repeat = false)
    if Rails.env.production?
      MailingService.sync_with_mapmimi

      MailingService.users_to_mail_now.each do |user|
        UserNotifier.weekly_notification(user.id).deliver_later
        user.update_attributes!({ :next_mailing_at => Time.now + 7.days + rand(-12..12).hours })
      end

      if repeat
        MailingService.delayed_send_mailing
      end
    end
  end

  def self.users_to_mail_now(use_madmimi = true)
    mail_users = User.registered.where(:mailing_unsubscribe => false)
                                .where('next_mailing_at < ?', Time.now)
                                .to_a

    # Reject from list if not in the madmimi list
    if use_madmimi
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
    end

    # Reject from list if user solved a level too soon
    mail_users = mail_users.keep_if do |user|
      user.scores.where('created_at > ?', Time.now - TOO_SOON).empty?
    end

    # Reject from list if user didn't solve a level in the last 3 months (bad mail or user didn't care)
    mail_users = mail_users.delete_if do |user|
      user.scores.where('created_at > ?', Time.now - TIME_BEFORE_INACTIVE).empty?
    end

    mail_users
  end

  def self.sync_with_mapmimi
    bdd_mails                = User.registered.where(:mailing_unsubscribe => false).collect(&:email)
    bdd_suppressed_mails     = User.registered.where(:mailing_unsubscribe => true).collect(&:email)
    mapmimi_mails            = MailingService.mapmimi_mails
    mapmimi_suppressed_mails = MailingService.mapmimi_suppressed_mails

    # if mail in bdd and not in mapmimi, add it
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
      user = User.where(:email => mail).try(:first)
      user.update_attributes!({ :mailing_unsubscribe => true }) if user
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

