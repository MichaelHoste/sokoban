class AddCreatedAtIndexToLevelUserLinks < ActiveRecord::Migration
  def change
    # scores (level_user_links)
    add_index :level_user_links, :created_at
  end
end
