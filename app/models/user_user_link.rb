class UserUserLink < ActiveRecord::Base

  # Constants
  
  # Attributes
  attr_protected :created_at, :updated_at
  
  # Associations
  belongs_to :user,
             :class_name  => 'User',
             :primary_key => 'f_id'
  
  belongs_to :friend,
             :class_name  => 'User',
             :primary_key => 'f_id'
  
  # Nested attributes
  
  # Validations
  
  # Callbacks
  
  # Methods
  
end




 