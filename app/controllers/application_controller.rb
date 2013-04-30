class ApplicationController < ActionController::Base
  include AuthorizationFilters

  protect_from_forgery

  helper_method :current_user
  before_filter :check_facebook

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def check_facebook
    if current_user and current_user.f_expires_at < Time.now                    # user is connected but session is expired
      redirect_to '/auth/facebook'
    elsif not current_user and (params[:fb_source] or params[:signed_request])  # On each click on facebook to the application
      if params[:pack_id] and params[:id]                                       # if click on notification or feed with specific level, keep it on redirected params
        pack   = Pack.find_by_name(params[:pack_id])
        @level = pack.levels.find_by_name(params[:id])
      elsif params[:level_id]
        @level = Level.find(params[:level_id])                                  # if redirected by notification
      end
      render 'layouts/canvas_redirect', :layout => false                        # canvas redirect to facebook oauth (register or log user)
    elsif params[:controller].in?(['levels', 'packs']) and params[:level_id]
      @level = Level.find(params[:level_id])
      redirect_to pack_level_path(@level.pack.name, @level.name)
    end
  end
end
