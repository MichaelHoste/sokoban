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
           :class_name => 'LevelUserLink',
           :order      => 'pushes ASC, moves ASC, created_at DESC'

  has_many :best_scores,
           :class_name => 'LevelUserLink',
           :order      => 'pushes ASC, moves ASC, created_at DESC',
           :conditions => { :best_level_user_score => true }

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

  # get next level from this pack (first from the pack if last level)
  def next_level
    next_level = Level.where(:id => self.id + 1)

    if not next_level.empty?
      if next_level.first.pack_id == self.pack_id
        next_level.first
      else
        self.pack.levels.first
      end
    else
      self.pack.levels.first
    end
  end

  # Get count of unique scores for this level
  def unique_scores_count
    # distincts users + anonymous users (NULL is not a distinct user)
    self.best_scores.count
  end

  # Get count of unique scores for this level
  def unique_friends_scores_count(user)
    self.best_scores.where(:user_id => user.friends + [user.id]).count
  end

  # generate an image of the level in /public/images/levels
  def generate_thumb
    unless File.exist?("public/images/levels/#{self.id}.png")
      @pack  = self.pack
      @level = self
      @grid  = self.grid_with_floor

      @grid.each_with_index do |row, index|
        row = row.gsub(' ', 'empty64:png ')
        row = row.gsub('s', 'floor64:png ')
        row = row.gsub('.', 'goal64:png ')
        row = row.gsub('#', 'wall64:png ')
        row = row.gsub('$', 'box64:png ')
        row = row.gsub('*', 'boxgoal64:png ')
        row = row.gsub('@', 'pusher64:png ')
        row = row.gsub('+', 'pushergoal64:png ')
        row = row.gsub(':', '.')

        `cd public/images/themes/classic;convert #{row} +append ../../levels/row_#{index+1}.png`
      end

      command = ""
      (1..self.height).to_a.each do |m|
        command = command + "row_#{m}.png "
      end

      `cd public/images/levels;convert #{command} -append #{self.id}.png`
      `cd public/images/levels;rm -f row_*.png`
    end
  end

  def thumb
    "https://sokoban.be/images/levels/#{self.id}.png"
  end

  def best_global_scores(user, count)
    scores = self.best_scores.limit(count)
    LevelUserLink.tag_worse_scores_than_user(scores, user ? user.id : 0)
  end

  def best_friends_scores(user, count)
    scores = user ? self.best_scores.where(:user_id => user.friends.registred.pluck('users.id') + [user.id]).limit(count) : []
    LevelUserLink.tag_worse_scores_than_user(scores, user ? user.id : 0)
  end
end
