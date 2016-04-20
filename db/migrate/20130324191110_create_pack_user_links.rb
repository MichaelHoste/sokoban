class CreatePackUserLinks < ActiveRecord::Migration
  def change
    create_table :pack_user_links do |t|
      t.integer :pack_id
      t.integer :user_id
      t.integer :won_levels_count, :default => 0
      t.text    :won_levels_list

      t.timestamps
    end

    # Populate PackUserLinks (not-optimized-at-all-but-dont-care-because-only-executed-once)
    LevelUserLink.all.each do |score|
      PackUserLink.where(:pack_id => score.level.pack_id, :user_id => score.user_id).first_or_create.update_stats
    end
  end
end
