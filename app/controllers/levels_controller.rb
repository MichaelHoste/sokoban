class LevelsController < ApplicationController
  def show
    @pack = Pack.find_by_name(params[:pack_id])
    @level = @pack.levels.find_by_name(params[:id])
    @selected_level_name = params[:id]

    respond_to do |format|
      format.html do
        @pushes_scores         = @level.best_scores.limit(6)
        if current_user
          @pushes_scores_friends = @level.best_scores.where(:user_id => current_user.friends + [current_user.id])
                                                     .limit(6)
        else
          @pushes_scores_friends = []
        end
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
