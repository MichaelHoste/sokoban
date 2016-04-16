class AddBestLevelUserScoreIndex < ActiveRecord::Migration
  def change
     add_index :level_user_links, :best_level_user_score
  end
end
