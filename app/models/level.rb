class Level < ActiveRecord::Base

  # Constants
  
  # Attributes
  attr_protected :created_at, :updated_at
  
  # Associations
  belongs_to :pack
  
  # Nested attributes
  
  # Validations
  
  # Callbacks
  
  # Methods

end
