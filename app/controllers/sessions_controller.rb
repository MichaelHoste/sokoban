class SessionsController < ApplicationController
  def new
    if current_user
      redirect_to :root
    else
      render :layout => false
    end
  end

  def create
    credentials = request.env['omniauth.auth']['credentials']

    Rails.logger.info("CRED #{credentials.inspect}")

    @user = User.update_or_create(credentials)

    if @user.save!
      session[:user_id] = @user.id
      @user.build_friendships

      if params[:fb_source] == 'notification'
        level = Level.find(params[:level_id])
        redirect_to pack_level_path(level.pack.name, level.name)
      else
        redirect_to :root
      end
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
