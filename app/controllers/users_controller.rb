class UsersController < ApplicationController
  def popular_friends
    @user = User.find(params[:id])
    @popular_friends = @user.popular_friends(6)
    render 'popular_friends', :layout => false
  end

  def is_like_facebook_page
    @user = User.find(params[:id])
    @user.like_fan_page = @user.request_like_fan_page?
    @user.save!
    render :json => { :like => @user.like_fan_page }
  end

  def update_send_invitations_at
    @user = User.find(params[:id])
    @user.update_attributes!({ :send_invitations_at => Time.now })
    render :json => {}
  end
end
