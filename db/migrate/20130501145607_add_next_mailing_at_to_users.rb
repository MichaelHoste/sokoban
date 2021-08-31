class AddNextMailingAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :next_mailing_at, :datetime, :default => Time.now - 10.days

    User.reset_column_information

    User.registered.each do |user|
      user.update!({ :next_mailing_at => Time.now + rand(1..7).days + rand(1..24).hours })
    end
  end
end
