class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def banner
    @pack = Pack.find_by_name(params[:pack_name])
    render :partial => 'layouts/banner'
  end

  def privacy_policy
    render 'layouts/privacy_policy', :layout => false
  end

  def terms_of_service
    render 'layouts/terms_of_service', :layout => false
  end

  def stats
    @total_users   = User.registred.count
    @total_friends = User.not_registred.count
    @total_scores  = LevelUserLink.count
    @best_scores   = LevelUserLink.where(:best_level_user_score => true).count
    @last_users    = User.registred.order('updated_at DESC').limit(10)
    @last_scores   = LevelUserLink.unscoped.order('created_at DESC').limit(100)
    render 'layouts/stats', :layout => false
  end
end
