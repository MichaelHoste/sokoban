class WorkflowsController < ApplicationController
  def show_welcome
    cookies[:already_read_the_welcome_message] = { :value => "1",
                                                   :expires => 7.days.from_now }
    render :layout => false
  end

  def show_controls
    render :layout => false
  end

  def show_rules
    @pack = Pack.find_by_name('Original & Extra')
    @level = @pack.levels.find_by_name('1')

    @grid1 = @level.inline_grid_with_floor
    @grid2 = @level.inline_grid_with_floor.gsub('$', 's').gsub('.', '*').gsub('@', 's')
    @grid2['s**'] = '@**'

    render :layout => false
  end

  def show_challenges_and_packs
    render :layout => false
  end

  def show_facebook_page
    render :layout => false
  end

  def show_twitter_page
    render :layout => false
  end

  def show_invite_friends
    @friends = current_user.friends.not_registered.order('friends_count DESC').take(80)
    render :layout => false
  end

  def show_random_level
    @level = Level.random(current_user)
    render :layout => false
  end

  def show_donation
    render :layout => false
  end

  def show_next_level
    @level = Level.find(params[:level_id])
    @pack  = @level.pack

    @score = LevelUserLink.find(params[:score_id])

    @ladder = @score.ladder_friends(5)

    @next_level = @level.next_level

    render :layout => false
  end
end
