class AddLikeFanPageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :like_fan_page, :boolean, :default => false
  end
end
