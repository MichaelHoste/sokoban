class PacksController < ApplicationController
  def index
    @packs = Pack.all
  end
  
  def show
    @pack = Pack.find_by_name(params[:id])
    @level = @pack.levels.first
    @selected_level_name = @level.name
    
    @pushes_scores = @level.pushes_scores
    @pushes_scores_friends = @level.pushes_scores_friends(current_user)
  end
end
