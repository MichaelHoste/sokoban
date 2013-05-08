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

  # Class Methods

  def self.random(user = nil)
    level = nil
    while not level
      number = rand(1..5)
      if number <= 3
        level = Level.friends_random(user)
      elsif number == 4
        level = Level.complexity_random(user)
      else
        level = Level.users_random(user)
      end
    end
    level
  end

  # scope = scope of the randomness (if scope = 10 then only 10 to 100 first levels are preselected)
  def self.complexity_random(user = nil, scope = 10)
    if user and user.best_scores.pluck(:level_id).count != 0
      levels = Level.where('id not in (?)', user.best_scores.pluck(:level_id))
    else
      levels = Level
    end

    limit = rand(1..10) * scope # More chance to get first easiest levels
    levels.order('complexity ASC').limit(limit).sample
  end

  # scope = scope of the randomness (if scope = 10 then only 10 to 100 first levels are preselected)
  def self.users_random(user = nil, scope = 10)
    if user and user.best_scores.pluck(:level_id).count != 0
      levels = Level.where('id not in (?)', user.best_scores.pluck(:level_id))
    else
      levels = Level
    end

    limit = rand(1..10) * scope # More chance to get first easiest levels
    levels.order('won_count DESC').limit(limit).sample
  end

  def self.friends_random(user)
    if user
      completed_levels = user.best_scores.pluck(:level_id)
      friend_level_ids = user.friends.registered.collect do |friend|
        if completed_levels.count != 0
          friend.best_scores.where('level_id not in (?)', completed_levels).pluck(:level_id)
        else
          friend.best_scores.pluck(:level_id)
        end
      end.flatten

      occurrences   = friend_level_ids.inject(Hash.new(0)) { |h,v| h[v] += 1; h } # hash { level_id => occurences } like { 2227=>34, 2230=>26, 2229=>28, 2231=>25, 2233=>21, 2238=>19 }
      occurrences   = occurrences.to_a.sort_by { |x| x[1] }.reverse               # Convert hash to array and sort it by number of occurrences
      occurrence_id = occurrences.take(occurrences.count / 10 + 1).sample         # Take one occurrence from the top 1O

      if not occurrence_id
        return nil
      else
        occurrence_id = occurrence_id[0]
      end

      selected_level = Level.where(:id => occurrence_id)
      selected_level.empty? ? nil : selected_level.first
    else
      nil
    end
  end

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
  def friends_scores_count(user)
    self.best_scores.where(:user_id => user.friends.registered + [user.id]).count
  end

  def friends_scores_names(user)
    self.best_scores.where(:user_id => user.friends.registered + [user.id])
                    .collect { |score| score.user.name }
  end

  def all_scores_names
    self.best_scores.where('user_id IS NOT NULL')
                    .collect { |score| score.user.name }
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
    "https://sokoban-game.com/images/levels/#{self.id}.png"
  end

  def best_global_scores(user, count)
    scores = self.best_scores.limit(count)
    LevelUserLink.tag_worse_scores_than_user(scores, user ? user.id : 0)
  end

  def best_friends_scores(user, count)
    scores = user ? self.best_scores.where(:user_id => user.friends.registered.pluck('users.id') + [user.id]).limit(count) : []
    LevelUserLink.tag_worse_scores_than_user(scores, user ? user.id : 0)
  end
end
