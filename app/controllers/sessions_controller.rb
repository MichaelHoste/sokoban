class SessionsController < ApplicationController

  skip_before_action :check_facebook

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
          UserUserLink.recompute_counts_for_user(@user.id)
        end
      end

      if session['referer_level_id']
        level = Level.find_by_id(session['referer_level_id'])
        session.delete('referer_level_id')
        redirect_to pack_level_path(level.pack, level)
      elsif session['referer_user_id']
        user = User.find_by_id(session['referer_user_id'])
        session.delete('referer_user_id')
        redirect_to user_path(user)
      elsif session['referer'] and not session['referer'].empty?
        redirect_to session['referer']
      else
        redirect_to :root
      end
    else
      error_message = @user.errors.full_messages.join(", ")

      # Notify via email (delete if airbrake works)
      UserNotifier.error_to_admin(error_message).deliver_later

      # Notify via airbrake
      Airbrake.notify(
        :error_class   => "Registration error",
        :error_message => "Registration error : #{error_message}",
        :parameters    => {}
      )

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
