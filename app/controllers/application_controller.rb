class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  # get hash of banner infos : {:id_54 => '233,455', :id_66 => '444,666'}
  def banner
    hash = {:success => {}, :count => {}}

    if current_user
      pack = (params[:pack_name] ? Pack.find_by_name(params[:pack_name]) : nil)
      current_user.subscribed_friends_and_me(pack).each do |user|
        won_levels = user.won_levels_list(pack)
        hash[:success][user.id] = won_levels.join(',')
        hash[:count][user.id] = "#{user.name} - #{won_levels.count}"
      end
    end

    render :json => hash
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
    render 'layouts/stats'
  end
end
