# check if max_width and max_height are correct
# SELECT Max(l.width), p.max_width FROM packs AS p, levels AS l WHERE p.id = l.pack_id GROUP BY p.id
class Pack < ActiveRecord::Base

  # Constants
  
  # Attributes
  attr_protected :created_at, :updated_at
  
  # Associations
  has_many :levels
  
  # Scope
  default_scope :order => 'name ASC'
  
  # Nested attributes
  
  # Validations
  
  # Callbacks
  
  # Methods
  
  def self.won_levels_ids(current_user)
    if current_user
      # Get unique level_id from all the scores for current_user related to this pack
      current_user.scores.pluck(:level_id).uniq
    else
      []
    end
  end
  
  def won_levels_ids(current_user)
    if current_user
      # Get unique level_id from all the scores for current_user related to this pack
      current_user.scores.where(:level_id => self.levels).pluck(:level_id).uniq
    else
      []
    end
  end
  
end
