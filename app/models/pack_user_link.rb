class PackUserLink < ActiveRecord::Base

  # Attributes

  attr_protected :created_at, :updated_at

  # Associations

  belongs_to :pack
  belongs_to :user

  # Validations

  validates :pack_id, :user_id, :won_levels_count, :won_levels_list,
            :presence => true

  # Callbacks

  # Methods

  def update_stats
    if self.user # not anonymous score
      self.won_levels_count = self.user.won_levels_count(self.pack)
      self.won_levels_list  = self.user.won_levels_list(self.pack)
      self.save!
    end
  end
end
