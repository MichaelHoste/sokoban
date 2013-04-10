class AddSendInvitationsAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :send_invitations_at, :datetime, :default => Time.now.to_date - 30.days, :after => :friends_updated_at
  end
end
