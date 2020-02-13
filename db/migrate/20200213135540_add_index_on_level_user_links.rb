class AddIndexOnLevelUserLinks < ActiveRecord::Migration
  def change
    add_index :level_user_links, [:pushes, :moves, :created_at]
  end
end
