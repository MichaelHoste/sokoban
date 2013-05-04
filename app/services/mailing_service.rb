module MailingService
  # Automatic mailing (every 7 days unless the user was active less than 48hours ago)
  def self.delayed_send_mailing
    Delayed::Job.where(:queue => 'send_mailing').destroy_all
    MailingService.delay(:run_at => Time.now + 30.minutes, :queue => 'send_mailing').send_mailing(true)
  end

  def self.send_mailing(repeat = false)
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
end

