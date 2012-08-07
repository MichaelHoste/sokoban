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
      if current_user and Rails.env == 'production'
        @score.publish_on_facebook  # open graph
      end
      
      render :json => { :success  => true,
                        :score_id => @score.id }
    else
      render :json => { :success => false,
                        :result  => @score.errors.full_messages.join(", ") }
    end
  end
  
  # Called in AJAX when level changes (similar to show in pack controller)
  def index
    @pack = Pack.find_by_name(params[:pack_id])
    @level = @pack.levels.find_by_name(params[:level_id])
    @global_rows = params[:global_score_page].to_i*8 - 1
    @friend_rows = params[:friend_score_page].to_i*8 - 1
   
    # Take first two rows of friends and public scores
    @pushes_scores = @level.pushes_scores(@global_rows*2)[0..@global_rows]
    @pushes_scores_friends = @level.pushes_scores_friends(current_user, @friend_rows*2)[0..@friend_rows]
   
    render :partial => 'level_user_links/index'
  end
end
