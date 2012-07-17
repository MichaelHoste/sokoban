class LevelsController < ApplicationController
  layout "empty", :except => [:show]
  
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
  
  def thumb
    @pack = Pack.find_by_name(params[:pack_id])
    @level = @pack.levels.find_by_name(params[:level_id])
    @grid = @level.grid_with_floor
    
    @grid.each_with_index do |row, index|
      row = row.gsub(' ', 'empty64:png ')
      row = row.gsub('s', 'floor64:png ')
      row = row.gsub('.', 'goal64:png ')
      row = row.gsub('#', 'wall64:png ')
      row = row.gsub('$', 'box64:png ')
      row = row.gsub('*', 'boxgoal64:png ')
      row = row.gsub('@', 'pusher64:png ')
      row = row.gsub('+', 'pushergoal64:png ')
      row = row.gsub(':', '.')
      
      `cd public/images/;convert #{row} +append row_#{index+1}.png`
    end
  
    command = ""
    (1..@level.height).to_a.each do |m|
      command = command + "row_#{m}.png "
    end
    
    `cd public/images/;convert #{command} -append #{@level.id}.png`
    `cd public/images/;rm -f row_*.png`
  end
end
