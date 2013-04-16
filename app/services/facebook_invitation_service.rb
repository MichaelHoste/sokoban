module FacebookInvitationService
  # return a json with
  #   * a popular non-registered user friend to user
  #   * a custom name "x friends are on Sokoban"
  #   * a custom message "x and x and 3 more friends are here, come and join us!"
  def self.popular_invitation(user)
    Rails.logger.info("friends : #{user.friends.collect(&:name)}")

    if user.friends.not_registered.count == 0
      return { :f_id => nil, :name => '', :description => '' }
    else
      friend = []
      i = 0
      while friend.empty? or friend.first.registered?
        friend = user.popular_friends(1)
        if i >= 20
          return { :f_id => nil, :name => '', :description => '' }
        end
        i = i + 1
      end
      friend = friend.first

      # list of registered friends of this user's not registered friend
      friend_friends = UserUserLink.where(:friend_id => friend.f_id)
                                   .where('user_id != ?', user.f_id)
                                   .collect { |u_u| u_u.user }
                                   .keep_if { |u_user| u_user.registered? }
                                   .collect(&:name).shuffle

      count = friend_friends.count

      if friend_friends.count <= 4
        friend_friends  << 'me'
        list_of_friends = friend_friends.to_sentence(:last_word_connector => ' and ')
      else
        friend_friends  = friend_friends.insert(4, 'me')
        list_of_friends = friend_friends.take(5).join(', ') + " and #{friend_friends.count - 5} more friends"
      end

      return {
        :f_id    => friend.f_id,
        :name    => "#{friend_friends.count} of your friends are on Sokoban",
        :message => "Come and join #{list_of_friends} on Sokoban. This addictive puzzle-game will blow your mind!"
      }
    end
  end
end
