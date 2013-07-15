class AddLevelsToSolveCountAndScoresToImproveCountToUserUserLinks < ActiveRecord::Migration
  def change
    add_column :user_user_links, :levels_to_solve_count,   :integer, :default => 0, :null => false
    add_column :user_user_links, :scores_to_improve_count, :integer, :default => 0, :null => false
  end
end
