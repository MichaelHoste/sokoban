class WorkflowsController < ApplicationController
  def show
    @view_name = params[:id]
    
    if @view_name == 'next_level'
      @pack_name = params[:pack_name]
      @level_name = params[:level_name]
      
      @pack = Pack.find_by_name(@pack_name)
      @level = @pack.levels.find_by_name(@level_name)
      @score = LevelUserLink.find(params[:score_id])
      
      @next_level = @level.next_level
    end
    
    render 'show_' + @view_name, :layout => false,
  end
end
