class LevelsController < ApplicationController
  def show
    @pack = Pack.find_by_name(params[:pack_id])
    @level = @pack.levels.find_by_name(params[:id])
    @selected_level_name = params[:id]
    
    respond_to do |format|
      format.html do
        @pushes_scores = @level.pushes_scores
        @pushes_scores_friends = @level.pushes_scores_friends(current_user)
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
