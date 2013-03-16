class AddBestLevelUserScoreToLevelUserLinks < ActiveRecord::Migration
  def up
    add_column :level_user_links, :best_level_user_score, :boolean, :default => false, :null => false

    # tag best_level_user_score to true

    # when anonymous, always best score
    LevelUserLink.where('user_id IS NULL').each do |score|
      score.best_level_user_score = true
      score.save!
    end

    # when not anonymous, test if best score
    LevelUserLink.where('user_id IS NOT NULL').each do |score|
      l_u = LevelUserLink.where(:user_id => score.user_id, :level_id => score.level_id)
                         .where('pushes < :p or (pushes = :p and moves < :m) or (pushes = :p and moves = :m and created_at > :c)',
                                :p => score.pushes, :m => score.moves, :c => score.created_at)
      score.best_level_user_score = l_u.empty? ? true : false
      score.save!
    end
  end

  def down
    remove_column :level_user_links, :best_level_user_score
  end
end
