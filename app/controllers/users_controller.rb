class UsersController < ApplicationController

  before_filter :require_user, :only   => ['levels_to_solve', 'scores_to_improve']
  before_filter :find_user,    :except => ['index']
  before_filter :get_ladder,   :only   => ['show', 'levels_to_solve', 'scores_to_improve']
  before_filter :get_friends,  :only   => ['show', 'levels_to_solve', 'scores_to_improve']

  def show
    level_ids = @user.best_scores.order('created_at DESC').limit(60).pluck(:level_id)
    @levels   = find_levels_and_preserve_order(level_ids)
  end

  def levels_to_solve
    current_user_level_ids = current_user.best_scores.pluck(:level_id)
    user_level_ids         = @user       .best_scores.pluck(:level_id)
    level_ids              = user_level_ids - current_user_level_ids
    @levels = find_levels_and_preserve_order(level_ids).take(60)

    render 'show'
  end

  def scores_to_improve
    current_user_level_ids = current_user.best_scores.pluck(:level_id)
    user_level_ids         = @user       .best_scores.pluck(:level_id)
    common_level_ids       = user_level_ids & current_user_level_ids

    current_user_scores = current_user.best_scores.where(:level_id => common_level_ids).order('level_id ASC').all
    user_scores         = @user       .best_scores.where(:level_id => common_level_ids).order('level_id ASC').all

    @levels = []
    @scores = []
    current_user_scores.each_with_index do |score, i|
      if score.pushes > user_scores[i].pushes or (score.pushes == user_scores[i].pushes and score.moves > user_scores[i].moves)
        @levels << score.level
        @scores << { :current_user_pushes => score.pushes,
                     :current_user_moves  => score.moves,
                     :user_pushes         => user_scores[i].pushes,
                     :user_moves          => user_scores[i].moves }
      end
    end
    @levels = @levels.take(60)
    @scores = @scores.take(60)

    render 'show'
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
    if current_user and params[:id] == 'me'
      redirect_to user_path(current_user)
    else
      @user = User.find(params[:id])
    end
  end

  def get_ladder
    @ladder = @user.ladder
  end

  def get_friends
    @friends  = @user.friends.registered.order('total_won_levels DESC')
  end

  # Preserve order of level_ids with "find"
  # http://stackoverflow.com/questions/1680627/activerecord-findarray-of-ids-preserving-order
  def find_levels_and_preserve_order(level_ids)
    unsorted_levels = Level.find(level_ids)
    level_ids.inject([]){|res, val| res << unsorted_levels.detect {|u| u.id == val}}
  end
end
