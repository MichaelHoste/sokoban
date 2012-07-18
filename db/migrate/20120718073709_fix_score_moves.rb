class FixScoreMoves < ActiveRecord::Migration
  def up
    LevelUserLink.all.each do |score|
      score.save!
    end
  end

  def down
  end
end
