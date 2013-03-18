class PacksController < ApplicationController
  def index
    @packs = Pack.all
  end

  def show
    @pack = Pack.find_by_name(params[:id])
    @level = @pack.levels.first
    @selected_level_name = @level.name

    # Take first two rows of friends and public scores
    # (other rows are displayed by scores_controller in AJAX)
    @pushes_scores         = @level.best_scores.limit(6)
    if current_user
      @pushes_scores_friends = @level.best_scores.where(:user_id => current_user.friends + [current_user.id])
                                                 .limit(6)
    else
      @pushes_scores_friends = []
    end
  end
end
