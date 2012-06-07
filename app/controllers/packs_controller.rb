class PacksController < ApplicationController
  def index
    @packs = Pack.all
  end
  
  def show
    @pack = Pack.find_by_name(params[:id])
    @level = @pack.levels.first
    @selected_level_name = @level.name
    @scores = @level.scores
    Rails.logger.info("AAA" + @scores.to_s)
  end
end
