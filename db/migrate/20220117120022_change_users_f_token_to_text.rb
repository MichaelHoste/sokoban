class ChangeUsersFTokenToText < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :f_token, :text
  end
end
