module FacebookNotificationService
  def self.notify_best_score(l_u, users, type)
    if type == 'better'
      text = "@[#{l_u.user.f_id}] has just beat your score on level '#{l_u.level.name}', get revenge!"
    else
      text = "@[#{l_u.user.f_id}] just solved '#{l_u.level.name}' with the same score as you."
    end

    if Rails.env.production?
      oauth        = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'])
      access_token = oauth.get_app_access_token
      graph        = Koala::Facebook::API.new(access_token)

      users.each do |user|
        # l_u.user (score) send notif to user (beaten score) and we log the date
        u_u = UserUserLink.find_by_user_id_and_friend_id(l_u.user.f_id, user.f_id)

        # Only one 'equality' notification every 30 minutes but every 'better' notifications
        if type == 'better' or (type == 'equality' and Time.now >= u_u.notified_at + 30.minutes.to_i)
          begin
            graph.put_connections(user.f_id, "notifications",
                                  :template => text,
                                  :href     => "?level_id=#{l_u.level.id}")
            u_u.update_attributes!({ :notified_at => Time.now })
          rescue
            Rails.logger.info("NOTIFICATION FAILED FOR BETTER #{user.name}")
          end
        end
      end
    end
  end

  # 'user' receive the notification of the 'friend' just registered
  def self.notify_registered_friend(user_id, friend_id)
    user   = User.find(user_id)
    friend = User.find(friend_id)

    text = "@[#{friend.f_id}] just registered and want to challenge you!"

    if Rails.env.production?
      oauth        = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'])
      access_token = oauth.get_app_access_token
      graph        = Koala::Facebook::API.new(access_token)

      begin
        graph.put_connections(user.f_id, "notifications",
                              :template => text,
                              :href     => "?user_id=#{friend_id}")
      rescue
        Rails.logger.info("NOTIFICATION FAILED FOR BETTER #{user.name}")
      end
    end
  end
end
