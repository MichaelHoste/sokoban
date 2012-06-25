class AddIndexesMovesPushes < ActiveRecord::Migration
  def up
    # scores (level_user_links)
    add_index :level_user_links, :pushes
    add_index :level_user_links, :moves
  end

  def down
    # scores (level_user_links)
    remove_index :level_user_links, :column => :pushes
    remove_index :level_user_links, :column => :moves
  end
end
