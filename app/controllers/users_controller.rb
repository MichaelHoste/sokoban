class UsersController < ApplicationController

  before_filter :find_user, :except => ['index']

  def show
  end

  def index
    if current_user
      @ladder = current_user.ladder
    else
      @ladder = User.find(1).ladder # Only general datas are used
    end
  end

  # HTML Templates

  def popular_friends
    @popular_friends = @user.popular_friends(6)
    render 'popular_friends', :layout => false
  end

  # JSON

  def is_like_facebook_page
    @user.like_fan_page = @user.request_like_fan_page?
    @user.save!
    render :json => { :like => @user.like_fan_page }
  end

  def update_send_invitations_at
    @user.update_attributes!({ :send_invitations_at => Time.now })
    render :json => {}
  end

  def custom_invitation
    render :json => FacebookInvitationService.popular_invitation(@user)
  end

  def unsubscribe_from_mailing
    if @user.created_at.to_i.to_s == params[:check]
      @user.unsubscribe_from_mailing
      render :text => "We successfully unsubscribed your email (#{@user.email}) from the mailing list."
    end
  end

  protected

  def find_user
    @user = User.find(params[:id])
  end
end
