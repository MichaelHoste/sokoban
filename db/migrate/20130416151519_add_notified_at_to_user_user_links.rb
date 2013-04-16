class AddNotifiedAtToUserUserLinks < ActiveRecord::Migration
  def change
    add_column :user_user_links, :notified_at, :datetime, :default => Time.now.to_date - 30.days, :after => :friend_id
  end
end
