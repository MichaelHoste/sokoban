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
  
  # counter_cache allows to get pack.levels.size without a count(*) request
  belongs_to :pack, :counter_cache => true
  
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
  
  def pushes_scores
    scores = self.scores.all
    improved_scores(scores)
  end
  
  def pushes_scores_friends(user)
    if not user
      []
    else
      scores = self.scores.where(:user_id => user.friends).all
      improved_scores(scores)
    end
  end
  
  private

  def improved_scores(scores)
    selected_scores = []
    selected_user_ids = []
    
    scores.each do |score|
      # if anonymous or first occurance of user (best score of this user)
      if score.user_id == nil or not selected_user_ids.include?(score.user_id)
        selected_user_ids << score.user_id
        selected_scores << score
      end 
    end
    
    selected_scores
  end
end
