class PacksController < ApplicationController
  def index
    @packs = Pack.all
  end

  def show
    @pack = Pack.find_by_name(params[:id])
    @level = @pack.levels.first

    # Take first two rows of friends and public scores
    # (other rows are displayed by scores_controller in AJAX)
    @pushes_scores         = @level.best_global_scores(current_user, 6)
    @pushes_scores_friends = @level.best_friends_scores(current_user, 6)
  end
end
