class PackUserLink < ApplicationRecord

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
      self.update_attributes!({ :won_levels_count => self.user.best_scores.where(:level_id => self.pack.level_ids).count,
                                :won_levels_list  => self.pack.won_levels_list(self.user) })
    end
  end
end



