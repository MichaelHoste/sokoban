class AddBestLevelUserScoreToLevelUserLinks < ActiveRecord::Migration
  def up
    add_column :level_user_links, :best_level_user_score, :boolean, :default => false, :null => false

    # tag best_level_user_score to true of false depending on if best user/level combo
    LevelUserLink.all.each do |score|
      score.tag_best_level_user_score
    end
  end

  def down
    remove_column :level_user_links, :best_level_user_score
  end
end
