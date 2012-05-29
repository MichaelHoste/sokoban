class AddIndexes < ActiveRecord::Migration
  def up
    # users
    add_index :users, :name
    add_index :users, :email
    
    # levels
    add_index :levels, :pack_id
    add_index :levels, :name
    
    # packs
    add_index :packs, :name
    
    # scores (level_user_links)
    add_index :level_user_links, :user_id
    add_index :level_user_links, :level_id
  end

  def down
    # users
    remove_index :users, :column => :name
    remove_index :users, :column => :email
    
    # levels
    remove_index :levels, :column => :pack_id
    remove_index :levels, :column => :name
    
    # packs
    remove_index :packs, :column => :name
    
    # scores (level_user_links)
    remove_index :level_user_links, :column => :user_id
    remove_index :level_user_links, :column => :level_id
  end
end
