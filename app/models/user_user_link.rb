class UserUserLink < ApplicationRecord

  # Associations
  belongs_to :user,
             :class_name  => 'User',
             :primary_key => 'f_id'

  belongs_to :friend,
             :class_name  => 'User',
             :primary_key => 'f_id'

  # Nested attributes

  # Validations

  validates_uniqueness_of :user_id, :scope => :friend_id

  # Callbacks

  # Class methods

  def self.recompute_all_count
    User.registered.all.each do |user|
      friend_f_ids = user.friends.registered.collect(&:f_id)
      UserUserLink.where(:user_id => user.f_id, :friend_id => friend_f_ids).all.each do |u_u|
        u_u.recompute_count
      end
    end
  end

  # WARNING : processor intensive !
  def self.recompute_counts_for_user(user_id)
    user = User.find(user_id)
    friend_f_ids = user.friends.registered.collect(&:f_id)

    UserUserLink.where(:user_id => user.f_id, :friend_id => friend_f_ids).all.each do |u_u|
      u_u.recompute_count
    end

    UserUserLink.where(:user_id => friend_f_ids, :friend_id => user.f_id).all.each do |u_u|
      u_u.recompute_count
    end
  end

  # Methods

  def recompute_count
    # levels that friend solved and not user
    # levels that friend solved better than user
    update_attributes!({ :levels_to_solve_count   => user.levels_to_solve(friend).count,
                         :scores_to_improve_count => user.scores_to_improve(friend)[:levels].count })
  end

  def total_improve_count
    levels_to_solve_count + scores_to_improve_count
  end
end
