class AddRegisteredAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :registered_at, :datetime, :after => :updated_at, :default => nil

    User.registered.each do |user|
      user.update!({ :registered_at => user.created_at })
    end

    add_index :users, :registered_at
  end
end
