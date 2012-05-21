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
  
end
