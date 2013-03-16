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

  # get next level from this pack (nil if last level)
  def next_level
    next_level = Level.where(:id => self.id + 1)

    # if next level exists and is in the same pack of the previous level
    if not next_level.empty? and next_level.first.pack_id == self.pack_id
      next_level.first
    else
      nil
    end
  end

  # Get count of unique scores for this level
  def unique_scores_count
    # distincts users + anonymous users (NULL is not a distinct user)
    self.scores.select('distinct user_id').count + self.scores.where('user_id IS NULL').count
  end

  # Get count of unique scores for this level
  def unique_friends_scores_count(user)
    self.scores.select('distinct user_id').where(:user_id => user.friends + [user.id]).count
  end

  # list of best pushes scores
  def pushes_scores(number)
    limit = number * 2
    best = []

    loop do
      scores = self.scores.limit(limit).all
      best = best_scores(scores)
      limit = limit * 2
      break if best.count >= number or best.count == self.scores.count or limit > 10000
    end

    best[0..number-1]
  end

  # list of best pushes scores for user friends
  def pushes_scores_friends(user, number)
    if not user
      []
    else
      limit = number * 2
      best = []

      loop do
        scores = self.scores.where(:user_id => user.friends.registred + [user.id]).limit(limit).all
        best = best_scores(scores)
        limit = limit * 2
        break if best.count >= number or best.count == self.scores.count or limit > 10000
      end

      best[0..number-1]
    end
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

  private

  # only keep best score for each users
  def best_scores(scores)
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
