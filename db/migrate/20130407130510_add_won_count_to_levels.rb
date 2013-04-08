class AddWonCountToLevels < ActiveRecord::Migration
  def change
    add_column :levels, :won_count, :integer, :after => :pusher_pos_n
    add_index :levels, :won_count

    Level.reset_column_information

    Level.all.each do |level|
      level.update_attributes!({ :won_count => level.best_scores.where('level_user_links.user_id IS NOT NULL').count })
    end
  end
end
