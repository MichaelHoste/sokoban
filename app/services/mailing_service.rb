module MailingService
  # Automatic mailing (every 7 days unless the user was active less than 48hours ago)
  def self.delayed_send_mailing
    Delayed::Job.where(:queue => 'send_mailing').destroy_all
    MailingService.delay(:run_at => Time.now + 10.minutes, :queue => 'send_mailing').send_mailing(true)
  end

  def self.send_mailing(repeat = false)
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

    mail_users.each do |user|
      # Delay mailing if user was connected less than 2 days ago
      recent_scores = user.scores.where('created_at > ?', Time.now - 2.days)
      if not recent_scores.empty?
        user.update_attributes!({ :next_mailing_at => Time.now + rand(20..32).hours })
      else
        UserNotifier.delay.weekly_notification(user.id)
        UserNotifier.delay.weekly_notification(user.id, true)
        user.update_attributes!({ :next_mailing_at => Time.now + 7.days + rand(-12..12).hours })
      end
    end

    if repeat
      MailingService.delayed_send_mailing
    end
  end
end

