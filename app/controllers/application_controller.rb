class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  # get hash of banner infos : {:id_54 => '233,455', :id_66 => '444,666'}
  def banner
    hash = {}
        
    if current_user
      pack = (params[:pack_name] ? Pack.find_by_name(params[:pack_name]) : nil)
      current_user.subscribed_friends_and_me(pack).each do |user|
        hash["id_#{user.id}"] = user.won_levels_ids(pack).join(',')
      end
    end
    
    render :json => hash
  end
end
