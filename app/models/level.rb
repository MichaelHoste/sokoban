class Level < ActiveRecord::Base

  # Constants
  
  # Attributes
  serialize :grid_with_floor
  serialize :grid
  
  attr_protected :created_at, :updated_at
  
  # Associations
  belongs_to :pack
  
  # Nested attributes
  
  # Validations
  
  # Callbacks
  
  # Methods
  def inline_grid_with_floor
    self.grid_with_floor.join
  end
  
  def cols_number
    self.width
  end
  
  def rows_number
    self.height
  end

end
