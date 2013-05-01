class AddMailingUnsubscribeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mailing_unsubscribe, :boolean, :default => false
  end
end
