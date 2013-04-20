class AddFullGameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :full_game, :boolean, :default => false
  end
end
