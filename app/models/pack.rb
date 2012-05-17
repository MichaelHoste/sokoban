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
