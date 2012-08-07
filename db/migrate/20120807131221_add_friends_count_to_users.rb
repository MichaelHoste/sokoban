class AddFriendsCountToUsers < ActiveRecord::Migration
  def up
    add_column :users, :friends_count, :integer, :default => 0, :null => false
    
    # update friends_count column
    User.all.each do |user|
      user.save
    end
  end
  
  def down
    remove_column :users, :friends_count
  end
end
