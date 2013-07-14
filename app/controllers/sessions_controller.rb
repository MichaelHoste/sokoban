class SessionsController < ApplicationController

  skip_before_filter :check_facebook

  def connect_facebook
    if not current_user
      session['referer'] = request.env["HTTP_REFERER"] || ''
      redirect_to '/auth/facebook'
    else
      redirect_to :back
    end
  end

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
        level = Level.find_by_id(params[:level_id])
        redirect_to pack_level_path(level.pack, level)
      elsif params[:user_id]
        user = User.find_by_id(params[:user_id])
        redirect_to user_path(user)
      elsif session['referer'] and not session['referer'].empty?
        redirect_to session['referer']
      else
        redirect_to :root
      end
    else
      error_message = @user.errors.full_messages.join(", ")
      UserNotifier.delay.error_to_admin(error_message)
      #Airbrake.notify(
      #  :error_class   => "Special Error",
      #  :error_message => "Special Error: #{e.message}",
      #  :parameters    => params
      #)

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
