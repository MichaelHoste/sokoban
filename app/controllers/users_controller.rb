class UsersController < ApplicationController

  before_action :require_user, :only   => ['levels_to_solve', 'scores_to_improve', 'destroy']
  before_action :find_user,    :except => ['index']
  before_action :get_ladder,   :only   => ['latest_levels', 'levels_to_solve', 'scores_to_improve']
  before_action :get_friends,  :only   => ['latest_levels', 'levels_to_solve', 'scores_to_improve']

  def show
    if !current_user || current_user.id == @user.id
      # Render latest levels (no redirection because default action)
      @ladder  = get_ladder
      @friends = get_friends
      @levels  = @user.latest_levels(60)
      render 'show'
    else
      if current_user.levels_to_solve(@user).count > 0
        redirect_to levels_to_solve_user_path(@user)
      elsif current_user.scores_to_improve(@user)[:levels].count > 0
        redirect_to scores_to_improve_user_path(@user)
      else
        redirect_to latest_levels_user_path(@user)
      end
    end
  end

  def latest_levels
    @levels = @user.latest_levels(60)
    render 'show'
  end

  def levels_to_solve
    @levels = current_user.levels_to_solve(@user, 60)
    render 'show'
  end

  def scores_to_improve
    levels_and_scores = current_user.scores_to_improve(@user)
    @levels = levels_and_scores[:levels].take(60)
    @scores = levels_and_scores[:scores].take(60)
    render 'show'
  end

  def index
    @page = params[:page] ? params[:page].to_i : 1

    if current_user
      @ladder = current_user.ladder(@page)
    else
      @ladder = User.find(1).ladder(@page) # Only general datas are used
    end

    if @page == 1
      render
    else
      render :layout => false
    end
  end

  def destroy
    if current_user.id == @user.id || current_user.admin?
      @user.remove_from_application
      session[:user_id] = nil
      redirect_to '/'
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
    @user.update!({ :send_invitations_at => Time.now })
    render :json => {}
  end

  def custom_invitation
    render :json => FacebookInvitationService.popular_invitation(@user)
  end

  def unsubscribe_from_mailing
    if @user.created_at.to_i.to_s == params[:check]
      @user.unsubscribe_from_mailing
      render :plain => "We successfully unsubscribed your email (#{@user.email}) from the mailing list."
    end
  end

  protected

  def find_user
    if current_user && params[:id] == 'me'
      redirect_to user_path(current_user)
    else
      @user = User.friendly.find(params[:id])
    end
  end

  def get_ladder
    @ladder = @user.ladder
  end

  def get_friends
    @friends  = @user.friends.registered.order('total_won_levels DESC')
  end
end
