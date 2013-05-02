class PagesController < ApplicationController

  before_filter :only_admins, :only => ['stats']

  def banner
    @pack = Pack.find(params[:pack_id])
    render :partial => 'layouts/banner'
  end

  def privacy_policy
    render 'layouts/privacy_policy', :layout => false
  end

  def terms_of_service
    render 'layouts/terms_of_service', :layout => false
  end

  def stats
    @total_users   = User.registered.count
    @total_friends = User.not_registered.count
    @total_scores  = LevelUserLink.count
    @best_scores   = LevelUserLink.where(:best_level_user_score => true).count
    @last_users    = LevelUserLink.order('created_at DESC').limit(200).collect { |l_u| l_u.user }.compact.uniq.take(20)
    @last_scores   = LevelUserLink.order('created_at DESC').limit(100)
    render 'layouts/stats', :layout => false
  end
end
