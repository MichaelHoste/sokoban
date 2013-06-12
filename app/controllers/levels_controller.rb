class LevelsController < ApplicationController
  def show
    @pack  = Pack.find(params[:pack_id])
    @level = @pack.levels.find(params[:id])

    if params[:json]
      render :json => { :grid        => @level.inline_grid_with_floor,
                        :pack_name   => @pack.name,
                        :level_name  => @level.name,
                        :copyright   => @level.copyright,
                        :rows_number => @level.rows_number,
                        :cols_number => @level.cols_number }
    else
      @pushes_scores         = @level.best_global_scores(current_user, 6)
      @pushes_scores_friends = @level.best_friends_scores(current_user, 6)
      render 'packs/show'
    end
  end
end
