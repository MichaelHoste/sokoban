class ScoresController < ApplicationController
  def create
    @level = Level.find(params[:level_id])
    @pack  = @level.pack

    @score = LevelUserLink.new(:user_id  => (current_user ? current_user.id : nil),
                               :level_id => @level.id)

    # score.path is not saved in the database, it is use to populate compressed
    # and uncompressed path when saving
    @score.path = params[:path]

    if @score.save
      @score.update_stats
      @score.delay.facebook_actions

      render :json => { :success  => true,
                        :score_id => @score.id }
    else
      render :json => { :success => false,
                        :result  => @score.errors.full_messages.join(", ") }
    end
  end

  # Called in AJAX when level changes (similar to show in pack controller)
  def index
    @level = Level.find(params[:level_id])
    @pack  = @level.pack
    @global_rows = params[:global_score_page].to_i*6
    @friend_rows = params[:friend_score_page].to_i*6

    # Take first two rows of friends and public scores
    @pushes_scores         = @level.best_global_scores(current_user, @global_rows)
    @pushes_scores_friends = @level.best_friends_scores(current_user, @friend_rows)

    render :partial => 'level_user_links/index'
  end
end
