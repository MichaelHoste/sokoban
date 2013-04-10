require 'v8'

class ValidatePath < ActiveModel::Validator
  # path is a uncompressed string
  def validate(score)
    path = score.uncompressed_path
    level = Level.find(score.level_id)
    is_won = false

    V8::C::Locker() do
      V8::Context.new do |cxt|
        cxt.eval('var window = new Object')
        cxt.load('lib/assets/path_core.js')
        cxt.load('lib/assets/level_core.js')

        cxt.eval('var path = new window.PathCore()')
        cxt.eval("path.create_from_uncompressed('#{path}')")

        cxt.eval('var level = new window.LevelCore()')
        cxt.eval("level.create_from_line('#{level.inline_grid}', #{level.width}, #{level.height}, '', '')")

        is_won = cxt.eval('level.is_solution_path(path)')
      end
    end

    score.errors.add(:base, "Path is not solution") if not is_won
  end
end

class LevelUserLink < ActiveRecord::Base

  # Constants

  # Attributes

  attr_accessor :path, :position, :worse
  attr_protected :created_at, :updated_at

  # Associations

  belongs_to :level
  belongs_to :user

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

  def facebook_actions
    self.publish_on_facebook
    self.notify_friends
  end

  # publish the "user has completed the level" on open graph (facebook)
  def publish_on_facebook
    if Rails.env.production? and self.user
      graph = Koala::Facebook::API.new(self.user.f_token)
      graph.put_connections("me", "sokoban_game:complete",
                            :level  => URI.escape("https://sokoban.be/packs/#{self.level.pack.name}/levels/#{self.level.name}"),
                            :pushes => self.pushes,
                            :moves  => self.moves)
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
                                     .where('pushes >= :p or (pushes = :p and moves >= :m)',
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

    puts("FRIENDS TO NOTIFY BETTER : #{friends_to_notify_better.collect(&:name).join(', ') }")
    puts("FRIENDS TO NOTIFY EQUALITY : #{friends_to_notify_equality.collect(&:name).join(', ') }")

    if Rails.env.production?
      oauth        = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'])
      access_token = oauth.get_app_access_token
      graph        = Koala::Facebook::API.new(access_token)

      facebook_notify(friends_to_notify_better, 'better')
      facebook_notify(friends_to_notify_equality, 'equality')
    end
  end

  def update_stats
    self.tag_best_score
    PackUserLink.find_or_create_by_pack_id_and_user_id(self.level.pack_id, self.user_id).update_stats
    self.user.update_attributes!({ :total_won_levels => self.user.pack_user_links.collect(&:won_levels_count).sum }) if self.user

    # delayed
    self.level.delay.update_attributes!({ :won_count => self.level.best_scores.where('level_user_links.user_id IS NOT NULL').count })
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
    ladder = self.level.best_scores.where(:user_id => self.user.friends.registered + [self.user_id]).all
    limited_ladder(ladder, num_of_scores)
  end

  def ladder(num_of_scores)
    ladder = self.level.best_scores.where('user_id IS NOT NULL').all
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

  def generate_pushes_and_moves()
    V8::C::Locker() do
      V8::Context.new do |cxt|
        cxt.eval('var window = new Object')
        cxt.load('lib/assets/path_core.js')
        cxt.eval('var path = new window.PathCore()')
        cxt.eval("path.create_from_uncompressed('#{self.uncompressed_path}')")
        self.pushes = cxt.eval('path.n_pushes')
        self.moves = cxt.eval('path.n_moves')
      end
    end
  end

  # compress path
  def compress_path(path)
    compressed_path = ""
    V8::C::Locker() do
      V8::Context.new do |cxt|
        cxt.eval('var window = new Object')
        cxt.load('lib/assets/path_core.js')
        cxt.eval('var path = new window.PathCore()')
        cxt.eval("path.create_from_uncompressed('#{path}')")
        compressed_path = cxt.eval("path.get_compressed_string_path()")
      end
    end
    compressed_path
  end

  # uncompres path
  def uncompress_path(path)
    uncompressed_path = ""
    V8::C::Locker() do
      V8::Context.new do |cxt|
        cxt.eval('var window = new Object')
        cxt.load('lib/assets/path_core.js')
        cxt.eval('var path = new window.PathCore()')
        cxt.eval("path.create_from_compressed('#{path}')")
        uncompressed_path = cxt.eval("path.get_uncompressed_string_path()")
      end
    end
    uncompressed_path
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

  private

  def facebook_notify(users, type)
    if type == 'better'
      text = "@[#{self.user.f_id}] has just beat your score on level '#{self.level.name}', get revenge!"
    else
      text = "@[#{self.user.f_id}] just solved '#{self.level.name}' with the same score as you, get revenge!"
    end

    users.each do |user|
      begin
        graph.put_connections(user.f_id, "notifications",
                              :template => text,
                              :href     => "?level_id=#{self.level.id}")
      rescue
        Rails.logger.info("NOTIFICATION FAILED FOR BETTER #{user.name}")
      end
    end
  end
end
