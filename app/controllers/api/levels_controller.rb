class Api::LevelsController < Api::BaseController
  def random
    @level = Level.random(current_user)
  end
end
