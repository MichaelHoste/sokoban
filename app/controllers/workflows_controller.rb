class WorkflowsController < ApplicationController
  def show_welcome
    cookies[:already_read_the_welcome_message] = { :value => "1",
                                                   :expires => 7.days.from_now }
    render 'show_welcome', :layout => false
  end

  def show_controls
    render 'show_controls', :layout => false
  end

  def show_rules
    @pack = Pack.find_by_name('Original & Extra')
    @level = @pack.levels.find_by_name('1')

    @grid1 = @level.inline_grid_with_floor
    @grid2 = @level.inline_grid_with_floor.gsub('$', 's').gsub('.', '*').gsub('@', 's')
    @grid2['s**'] = '@**'

    render 'show_rules', :layout => false
  end

  def show_challenges_and_packs
    render 'show_challenges_and_packs', :layout => false
  end

  def show_facebook_page
    render 'show_facebook_page', :layout => false
  end

  def show_random_level
    @level = Level.random(current_user)
    render 'show_random_level', :layout => false
  end

  def show_next_level
    @pack_name = params[:pack_name]
    @level_name = params[:level_name]

    @pack  = Pack.find_by_name(@pack_name)
    @level = @pack.levels.find_by_name(@level_name)
    @score = LevelUserLink.find(params[:score_id])

    @ladder = @score.ladder_friends(5)

    @next_level = @level.next_level

    render 'show_next_level', :layout => false
  end
end
