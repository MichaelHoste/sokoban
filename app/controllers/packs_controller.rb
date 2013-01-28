class PacksController < ApplicationController
  def index
    @packs = Pack.all
  end

  def show
    @pack = Pack.find_by_name(params[:id])
    @level = @pack.levels.first
    @selected_level_name = @level.name

    # Take first two rows of friends and public scores
    # (other rows are displayed by scores_controlelr in AJAX)
    @pushes_scores = @level.pushes_scores(30)[0..5]
    @pushes_scores_friends = @level.pushes_scores_friends(current_user, 30)[0..5]
  end
end
