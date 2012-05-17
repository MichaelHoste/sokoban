class CreateUserUserLinks < ActiveRecord::Migration
  def change
    create_table :user_user_links do |t|
      t.integer :id
      t.integer :user_id
      t.integer :friend_id

      t.timestamps
    end
    
    add_index :user_user_links, :user_id, :unique => true
    add_index :user_user_links, :friend_id
  end
end
