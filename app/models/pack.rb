class Pack < ApplicationRecord
  extend FriendlyId

  friendly_id :name, :use => :slugged

  # Associations
  has_many :levels
  has_many :pack_user_links
  has_many :users,           :through => :pack_user_links

  # Scope
  default_scope { order('name ASC') }

  # Nested attributes

  # Validations

  # Callbacks

  # Class Methods

  def self.won_level_ids(current_user)
    current_user ? current_user.scores.pluck(:level_id).uniq : []
  end

  def self.won_levels_list(current_user)
    won_level_ids(current_user).join(',')
  end

  # Methods

  def won_level_ids(current_user)
    current_user ? current_user.scores.where(:level_id => self.levels).pluck(:level_id).uniq : []
  end

  def won_levels_list(current_user)
    won_level_ids(current_user).join(',')
  end
end
