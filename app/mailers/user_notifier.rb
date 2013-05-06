# encoding: utf-8

class UserNotifier < ActionMailer::Base
  default :from => "\"Sokoban\" <contact@sokoban.be>"

  def new_user(user_name, user_email)
    @user_name  = user_name
    @user_email = user_email

    mail(:to      => 'contact@sokoban.be',
         :subject => "[Sokoban] New Registration : #{user_name}")
  end

  def weekly_notification(user_id, to_admin = false)
    @user  = User.find(user_id)
    @level = Level.friends_random(@user)
    if not @level
      @level = Level.random(@user)
    end

    @friend_names = @level.friends_scores_names(@user).shuffle
    @all_names    = @level.all_scores_names.shuffle

    if @friend_names.count == 0
      if @all_names.count == 0
        @text = "Can you solve this level?"
      elsif @all_names.count == 1
        @text = "This level has been solved by one person"
      else
        @text = "This level has been solved by #{@all_names.count} people"
      end
    else
      if @friend_names.count <= 4
        @text = @friend_names.to_sentence(:last_word_connector => ' and ') + " solved this level"
      else
        @text = @friend_names.take(4).join(', ') + " and #{@friend_names.count - 4} of your friends solved this level"
      end
    end

    @top_friends = (@user.friends.registered.all + [@user]).sort_by(&:total_won_levels).reverse
    @top_users   = User.registered.order('total_won_levels DESC').limit(10)

    @top_friends_position = @user.friends.registered.where('total_won_levels > ?', @user.total_won_levels).count + 1
    @top_users_position   = User.registered.where('total_won_levels > ?', @user.total_won_levels).count + 1

    mail(:to      => to_admin ? 'michael.hoste@gmail.com' : @user.email,
         :subject => @text)
  end
end
