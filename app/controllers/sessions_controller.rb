class SessionsController < ApplicationController
  def new
    if current_user
      redirect_to :root
    else
      render :layout => false
    end
  end

  def create
    # if already connected (facebook canvas is configured to redirect to this action)
    if session[:user_id]
      redirect_to :root
    end

    credentials = request.env['omniauth.auth']['credentials']
    @user = User.update_or_create(credentials)

    if @user.save!
      session[:user_id] = @user.id
      @user.build_friendships()
      # Get and save friends id of this user
      redirect_to :root
    else
      render :text => "Facebook connection failed (user informations could not be saved)"
    end
  end

  def failure
  end

  def destroy
    session[:user_id] = nil
    redirect_to :root
  end
end
