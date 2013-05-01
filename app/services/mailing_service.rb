module MailingService
  def self.delayed_send_mailing
    Delayed::Job.where(:queue => 'send_mailing').destroy_all
    MailingService.delay(:run_at => Time.now + 10.minutes, :queue => 'send_mailing').send_mailing(true)
  end

  def self.send_mailing(repeat = false)
    mail_users = User.registered.where(:mailing_unsubscribe => false)
                                .where('next_mailing_at < ?', Time.now)

    mail_users.each do |user|
      recent_scores = user.scores.where('created_at > ?', Time.now - 2.days)

      if recent_scores.empty?
        #UserNotifier.delay.weekly_notification(user.id)
        UserNotifier.delay.weekly_notification(user.id, true)
        user.update_attributes!({ :next_mailing_at => Time.now + 7.days + rand(-12..12).hours })
        if repeat
          MailingService.delayed_send_mailing
        end
      else
        user.update_attributes!({ :next_mailing_at => Time.now + rand(20..32).hours })
      end
    end
  end
end

