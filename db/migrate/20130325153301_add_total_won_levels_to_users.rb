class AddTotalWonLevelsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :total_won_levels, :integer, :null => false

    User.reset_column_information

    User.registred.all.each do |user|
      user.update_attributes!({ :total_won_levels => user.pack_user_links.collect(&:won_levels_count).sum })
    end
  end
end
