class AddFriendsUpdatedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :friends_updated_at, :datetime

    User.reset_column_information

    User.registered.all.each do |user|
      user.update_attributes!({ :friends_updated_at => Time.now.to_date - 5.days })
    end
  end
end
