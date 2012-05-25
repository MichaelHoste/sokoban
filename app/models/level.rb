# encoding: utf-8

# Find list of doublons
# SELECT l1.pack_id, l1.id, l1.name, l1.grid, l2.pack_id, l2.id, l2.name, l2.grid FROM levels AS l1, levels AS l2 WHERE l1.grid = l2.grid AND l1.id != l2.id

class Level < ActiveRecord::Base

  # Constants
  
  # Attributes
  serialize :grid_with_floor
  serialize :grid
  
  attr_protected :created_at, :updated_at
  
  # Associations
  belongs_to :pack
  
  has_many :scores,
           :class_name => 'LevelUserLink'
           
  has_many :users,
           :through => :scores
  
  # Nested attributes
  
  # Validations
  
  # Callbacks
  
  # Methods
  def inline_grid_with_floor
    complete_grid = Array.new(self.grid_with_floor)
    complete_grid.collect!{ |line| line + (1..self.width-line.length).collect { |n| ' ' }.join }
    complete_grid.join
  end
  
  def inline_grid
    complete_grid = Array.new(self.grid)
    complete_grid.collect!{ |line| line + (1..self.width-line.length).collect { |n| ' ' }.join }
    complete_grid.join
  end
  
  def cols_number
    self.width
  end
  
  def rows_number
    self.height
  end

end
