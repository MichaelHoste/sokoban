class SessionsController < ApplicationController
  def create
    auth_hash = request.env['omniauth.auth']

    render :text => auth_hash.inspect
  end
  
  def new
    render :layout => false
  end
  
  def failure
    
  end
end
