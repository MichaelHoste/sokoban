class SessionsController < ApplicationController
  def create
    credentials = request.env['omniauth.auth']['credentials']
    @user = User.find_or_create(credentials)

    if @user.save!
      redirect_to :root
    else
      render :text => "failed"
    end
  end
  
  def new
    render :layout => false
  end
  
  def failure
    
  end
end
