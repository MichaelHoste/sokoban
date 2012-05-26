# check if max_width and max_height are correct
# SELECT Max(l.width), p.max_width FROM packs AS p, levels AS l WHERE p.id = l.pack_id GROUP BY p.id
class Pack < ActiveRecord::Base

  # Constants
  
  # Attributes
  attr_protected :created_at, :updated_at
  
  # Associations
  has_many :levels
  
  # Nested attributes
  
  # Validations
  
  # Callbacks
  
  # Methods
  
  def won_level_ids(current_user)
    if current_user
      # Get all the scores for current_user and levels from this pack
      won_levels = current_user.scores.where(:level_id => self.levels)
      # Get ids from the levels of these scores. Each of these level is won
      won_levels.collect { |score| score.level_id }.uniq
    else
      []
    end
  end
  
end
