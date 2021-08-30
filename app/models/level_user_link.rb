class ValidatePath < ActiveModel::Validator
  # path is a uncompressed string
  def validate(score)
    level      = Level.find(score.level_id)
    core_level = Core::Level.new(level.inline_grid_with_new_lines)

    score.uncompressed_path.each_char { |move| core_level.move(move) }

    if !core_level.won?
      score.errors.add(:base, "Path is not solution")
    end
  end
end

class LevelUserLink < ApplicationRecord
  include Rails.application.routes.url_helpers

  # Constants

  # Attributes

  attr_accessor :path, :position, :worse

  # Associations

  belongs_to :level, :optional => true
  belongs_to :user,  :optional => true

  # Nested attributes

  # Validations

  validates_with ValidatePath

  # user_id can be null for anonymous scores
  validates :level_id, :uncompressed_path, :compressed_path, :pushes, :moves,
            :presence => true

  # Callbacks

  before_validation :populate_and_validate_score
  def populate_and_validate_score
    self.path = self.uncompressed_path if not self.path
    generate_paths(self.path)
    generate_pushes_and_moves()
  end

  # Scopes

  def self.best_before
    order('pushes ASC, moves ASC, created_at DESC')
  end

  # Class Methods

  def self.tag_worse_scores_than_user(array_of_scores, user_id)
    worse = false
    array_of_scores.each do |score|
      score.worse = worse ? true : false
      worse = true if score.user_id == user_id
      score
    end
  end

  # Methods

  # delayed when called
  def facebook_actions
    self.publish_on_facebook
    self.notify_friends

    if Rails.env.production? and LevelUserLink.count % 1000 == 0
      FacebookFeedService.delay.publish_level_count(LevelUserLink.count)
    end
  end

  # publish the "user has completed the level" on open graph (facebook)
  def publish_on_facebook
    if Rails.env.production? and self.user
      begin
        graph = Koala::Facebook::API.new(self.user.f_token)
        graph.put_connections("me", "sokoban_game:complete",
                              :level  => pack_level_url(self.level.pack, self.level, :host => "sokoban-game.com"),
                              :pushes => self.pushes,
                              :moves  => self.moves)
      rescue Koala::Facebook::APIError => e
        Rails.logger.info("PUBLISH ON FACEBOOK FAILED (but was published anyway ?)")
      end
    end
  end

  # App notifications : https://developers.facebook.com/docs/concepts/notifications/
  def notify_friends
    return false if not self.user

    # Get old best score (if any)
    best_score = self.user.best_scores.where(:level_id => self.level_id)
    if best_score.empty?
      old_best_score = []
    else
      old_best_score = self.user.scores.where(:level_id => self.level_id)
                                       .where('created_at < ?', best_score.first.created_at)
                                       .order('pushes ASC, moves ASC, created_at DESC')
    end

    # Get list lower or equal scores (friends !)
    friends_lower_scores = self.level.best_scores
                                     .where(:user_id => self.user.friends.registered.pluck('users.id'))
                                     .where('pushes > :p or (pushes = :p and moves >= :m)',
                                            :p => self.pushes, :m => self.moves)

    # If old best score, notify users between old best score and new score
    if not old_best_score.empty?
      friends_lower_scores = friends_lower_scores.where('pushes < :p or (pushes = :p and moves < :m)',
                                                        :p => old_best_score.first.pushes, :m => old_best_score.first.moves)
    end

    # Get list of friends to notify (Better score or equality score)
    friends_to_notify_better   = friends_lower_scores.collect { |score| score.user }
    friends_to_notify_equality = friends_lower_scores.where('pushes = :p and moves = :m',
                                                            :p => self.pushes, :m => self.moves)
                                                     .collect { |score| score.user }
    friends_to_notify_better = friends_to_notify_better - friends_to_notify_equality

    Rails.logger.info("FRIENDS TO NOTIFY BETTER : #{friends_to_notify_better.collect(&:name).join(', ') }")
    Rails.logger.info("FRIENDS TO NOTIFY EQUALITY : #{friends_to_notify_equality.collect(&:name).join(', ') }")

    FacebookNotificationService.notify_best_score(self, friends_to_notify_better, 'better')
    FacebookNotificationService.notify_best_score(self, friends_to_notify_equality, 'equality')
  end

  def update_stats
    # Tag user best score
    self.tag_best_score

    # Update user pack stats
    PackUserLink.where(:pack_id => self.level.pack_id, :user_id => self.user_id).first_or_create.update_stats

    if self.user
      # Update user stats
      self.user.update_attributes!({ :total_won_levels => self.user.pack_user_links.collect(&:won_levels_count).sum })

      # Update user_user stats (levels to solve, scores to improve)
      UserUserLink.delay.recompute_counts_for_user(self.user.id)
    end

    # Update level stats
    self.level.delay.update_attributes!({ :won_count => self.level.best_scores.count })
  end

  # Tag (only) the best score (best_level_user_score = true) for each level/user combo
  def tag_best_score
    if self.user_id == nil
      self.update_attributes!({ :best_level_user_score => true })
    else
      l_u = LevelUserLink.where(:user_id => self.user_id, :level_id => self.level_id)
                         .where('pushes < :p or (pushes = :p and moves < :m) or (pushes = :p and moves = :m and created_at > :c)',
                                :p => self.pushes, :m => self.moves, :c => self.created_at)
      if l_u.empty?
        LevelUserLink.where('id != ?', self.id).where(:user_id => self.user_id, :level_id => self.level_id).each do |score|
          score.update_attributes!({ :best_level_user_score => false })
        end
        self.update_attributes!({ :best_level_user_score => true })
      else
        self.update_attributes!({ :best_level_user_score => false })
      end
    end
  end

  def ladder_friends(num_of_scores)
    ladder = self.level.best_scores.where(:user_id => self.user.friends.registered + [self.user_id]).best_before.all
    limited_ladder(ladder, num_of_scores)
  end

  def ladder(num_of_scores)
    ladder = self.level.best_scores.where('user_id IS NOT NULL').best_before.all
    limited_ladder(ladder, num_of_scores)
  end

  # generate compressed and uncompressed paths
  def generate_paths(path)
    if path =~ /[0-9]/
      self.compressed_path = path
      self.uncompressed_path = uncompress_path(path)
    else
      self.uncompressed_path = path
      self.compressed_path = compress_path(path)
    end
  end

  def generate_pushes_and_moves
    path = Core::Path.new(self.uncompressed_path)

    self.pushes = path.pushes_count
    self.moves  = path.moves_count
  end

  # compress path
  def compress_path(path)
    Core::Path.new(path).compressed_string_path
  end

  # uncompres path
  def uncompress_path(path)
    Core::Path.new(path).uncompressed_string_path
  end

  # name of the user and 'visitor' if anonymous score
  def user_name
    self.user ? self.user.name : 'Anonymous'
  end

  private

  def limited_ladder(ladder, num_of_scores)
    # if current_score is not a best score, add it by hand on the ladder
    if self.best_level_user_score == false
      ladder = ladder.reject { |score| score.user_id == self.user_id } + [self]
    end

    user_index  = user_in_top_of_ladder(ladder)
    start_index = [user_index - (num_of_scores - 1),                0].max
    end_index   = [user_index + (num_of_scores - 1), ladder.count - 1].min

    while end_index - start_index >= num_of_scores
      if user_index - start_index > end_index - user_index
        start_index += 1
      else
        end_index -= 1
      end
    end

    # select restricted ladder and get absolute position
    restricted_ladder = ladder[start_index..end_index].each do |score|
      score.position = ladder.index(score) + 1
      score
    end

    LevelUserLink.tag_worse_scores_than_user(restricted_ladder, self.user ? self.user_id : 0)
  end

  # user must be in top of list of users with same scores
  def user_in_top_of_ladder(ladder)
    user_score_index = ladder.index(self)

    while user_score_index - 1 >= 0
      previous = ladder[user_score_index - 1]
      if (previous.pushes > self.pushes) or (previous.pushes == self.pushes and previous.moves >= self.moves)
        ladder[user_score_index - 1], ladder[user_score_index] = ladder[user_score_index], ladder[user_score_index - 1]
        user_score_index = user_score_index - 1
      else
        break
      end
    end

    return user_score_index
  end
end
