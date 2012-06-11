class PacksController < ApplicationController
  def index
    @packs = Pack.all
  end
  
  def show
    @pack = Pack.find_by_name(params[:id])
    @level = @pack.levels.first
    @selected_level_name = @level.name
    
    @best_pushes_score = @level.scores.limit(1)
    @best_moves_score  = @level.scores.order(:moves).limit(1)
    @scores = @level.scores.group(:user_id)
  end
end
