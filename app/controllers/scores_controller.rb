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
      @score.publish_on_facebook(request.protocol) if current_user
      @score.update_stats

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
    @global_rows = params[:global_score_page].to_i*6
    @friend_rows = params[:friend_score_page].to_i*6

    # Take first two rows of friends and public scores
    @pushes_scores         = @level.best_scores.limit(@global_rows)
    if current_user
      @pushes_scores_friends = @level.best_scores.where(:user_id => current_user.friends + [current_user.id])
                                                 .limit(@friend_rows)
    else
      @pushes_scores_friends = []
    end

    render :partial => 'level_user_links/index'
  end
end
