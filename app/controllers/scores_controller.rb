class ScoresController < ApplicationController
  def create
    @pack = Pack.find_by_name(params[:pack_id])
    @level = @pack.levels.find_by_name(params[:level_id])
    
    @score = LevelUserLink.new(:user_id  => current_user.id,
                               :level_id => @level.id)
    
    # score.path is not saved in the database, we need to check if the path
    # is compressed or uncompressed before saving it
    @score.path = params[:path]
    
    if @score.save
      render :json => { :result => "ok" }
    else
      render :json => { :result => @score.errors.full_messages.join(", ") }
    end
  end
end
