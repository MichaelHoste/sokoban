class SessionsController < ApplicationController

  skip_before_filter :check_facebook

  def new
    if current_user
      redirect_to :root
    else
      render :layout => false
    end
  end

  def create
    credentials = request.env['omniauth.auth']['credentials']
    @user = User.update_or_create(credentials)

    if @user.save!
      session[:user_id] = @user.id

      # update friendships if necessary (and delay only if not first time)
      if @user.has_to_build_friendships?
        if @user.friends_updated_at
          @user.delay.build_friendships
        else
          @user.build_friendships
        end
      end

      if params[:level_id]
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
