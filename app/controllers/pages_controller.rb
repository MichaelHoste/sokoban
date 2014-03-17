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

  def master_thesis
  end

  def stats
    @total_users   = User.registered.count
    @total_friends = User.not_registered.count
    @total_scores  = LevelUserLink.count
    @best_scores   = LevelUserLink.where(:best_level_user_score => true).count
    @distribution  = User.registered.group('total_won_levels').count
    @last_users    = User.registered.order('registered_at DESC').limit(20)
    @last_scores   = LevelUserLink.order('created_at DESC').limit(100)
    @jobs          = Delayed::Job.all

    @pending_mails = User.registered
                         .includes(:scores)
                         .where(:mailing_unsubscribe => false)
                         .where('next_mailing_at < ?', Time.now)
                         .where('level_user_links.created_at < ?', Time.now - MailingService::TOO_SOON)
                         .where('level_user_links.created_at > ?', Time.now - MailingService::TIME_BEFORE_INACTIVE).count

    @mails_by_week = User.registered
                         .includes(:scores)
                         .where(:mailing_unsubscribe => false)
                         .where('level_user_links.created_at > ?', Time.now - MailingService::TIME_BEFORE_INACTIVE).count

    render 'layouts/stats', :layout => false
  end
end
