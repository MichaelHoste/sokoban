class PacksController < ApplicationController
  def index
    @packs = Pack.all
  end
  
  def show
    @pack = Pack.find_by_name(params[:id])
    @level = @pack.levels.first
    @selected_level_name = @level.name
    
    @pushes_scores = @level.scores.select('MIN(pushes) as pushes, moves as moves, user_id, created_at')
                                  .group(:user_id)

    @pushes_scores_friends = @level.scores.select('MIN(pushes) as pushes, moves as moves, user_id, created_at')
                                          .where(:user_id => current_user.friends)
                                          .group(:user_id)
  end
end
