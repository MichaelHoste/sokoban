class LevelsController < ApplicationController
  def show
    # Levels/:id route
    if not params[:pack_id]
      @level = Level.find(params[:id])
      redirect_to pack_level_path(@level.pack.name, @level.name)
    # Packs/:pack_name/Levels/:level_name route
    else
      @pack  = Pack.find_by_name(params[:pack_id])
      @level = @pack.levels.find_by_name(params[:id])

      respond_to do |format|
        format.html do
          @pushes_scores         = @level.best_global_scores(current_user, 6)
          @pushes_scores_friends = @level.best_friends_scores(current_user, 6)
          render 'packs/show'
        end
        format.json do
          render :json => { :grid        => @level.inline_grid_with_floor,
                            :pack_name   => @pack.name,
                            :level_name  => @level.name,
                            :copyright   => @level.copyright,
                            :rows_number => @level.rows_number,
                            :cols_number => @level.cols_number }
        end
      end
    end
  end

  def random
    while not @level
      number = rand(1..5)
      if number <= 3
        @level = Level.friends_random(current_user)
      elsif number == 4
        @level = Level.complexity_random(current_user)
      else
        @level = Level.users_random(current_user)
      end
    end
    redirect_to pack_level_path(@level.pack.name, @level.name)
  end
end
