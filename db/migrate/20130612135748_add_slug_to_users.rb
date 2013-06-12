class AddSlugToUsers < ActiveRecord::Migration
  def change
    add_column :users, :slug, :string
    add_index  :users, :slug

    User.reset_column_information

    User.all.each do |user|
      user.save!
    end
  end
end
