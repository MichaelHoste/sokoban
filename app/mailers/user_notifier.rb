# encoding: utf-8

class UserNotifier < ActionMailer::Base
  default :from => "\"Sokoban\" <contact@sokoban.com>"

  def new_user(user_name, user_email)
    @recipient  = User.find(1)
    @user_name  = user_name
    @user_email = user_email

    mail(:to      => @recipient.email,
         :subject => "[Sokoban] Nouvel inscrit : #{user_name}")
  end
end
