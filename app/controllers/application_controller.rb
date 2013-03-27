class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  before_filter :check_facebook

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def check_facebook
    # user is connected but session is expired
    if current_user and current_user.f_expires_at < Time.now
      Rails.logger.info("1 : #{params.inspect}")
      redirect_to '/auth/facebook'
    elsif not current_user and params[:fb_source]
      Rails.logger.info("3 : #{params.inspect}")
      render :inline => "<script type = \"text/javascript\">
                           top.location.href='https://www.facebook.com/dialog/oauth?client_id=#{ENV['FACEBOOK_KEY']}&scope=#{ENV['FACEBOOK_SCOPE']}&redirect_uri=https://apps.facebook.com/sokojax/auth/facebook/callback'
                         </script>"
    end
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
