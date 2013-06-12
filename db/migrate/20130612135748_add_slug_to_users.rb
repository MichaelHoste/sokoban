class AddSlugToUsers < ActiveRecord::Migration
  def change
    add_column :users, :slug, :string
    add_index  :users, :slug

    User.reset_column_information

    User.find_each(&:save)
  end
end
