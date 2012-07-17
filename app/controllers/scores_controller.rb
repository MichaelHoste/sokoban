class ScoresController < ApplicationController
  def create
    @pack = Pack.find_by_name(params[:pack_id])
    @level = @pack.levels.find_by_name(params[:level_id])
    
    @score = LevelUserLink.new(:user_id  => (current_user ? current_user.id : nil),
                               :level_id => @level.id)
    
    # score.path is not saved in the database, it is use to populate compressed
    # and uncompressed path when saving
    @score.path = params[:path]
    
    if @score.save
      @score.publish_on_facebook  # open graph
      
      render :json => { :success  => true,
                        :score_id => @score.id }
    else
      render :json => { :success => false,
                        :result  => @score.errors.full_messages.join(", ") }
    end
  end
  
  def index
    @pack = Pack.find_by_name(params[:pack_id])
    @level = @pack.levels.find_by_name(params[:level_id])
    @pushes_scores = @level.pushes_scores
    @pushes_scores_friends = @level.pushes_scores_friends(current_user)
    
    render 'level_user_links/index', :layout => false
  end
end
