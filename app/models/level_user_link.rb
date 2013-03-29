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

  attr_accessor :path, :position
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

  # Methods

  def facebook_actions
    self.publish_on_facebook
    self.notify_friends
  end

  # publish the "user has completed the level" on open graph (facebook)
  def publish_on_facebook
    if Rails.env.production? and self.user
      graph = Koala::Facebook::API.new(self.user.f_token)
      graph.put_connections("me", "sokojax:complete",
                            :level  => URI.escape("https://sokoban.be/packs/#{self.level.pack.name}/levels/#{self.level.name}"),
                            :pushes => self.pushes,
                            :moves  => self.moves)
    end
  end

  # App notifications : https://developers.facebook.com/docs/concepts/notifications/
  def notify_friends
    if Rails.env.production? and self.user
      best_score     = self.user.best_scores.where(:level_id => self.level_id)
      old_best_score = self.user.scores.where(:level_id => self.level_id)
                                       .where('pushes >= :p or (pushes = :p and moves >= :m)',
                                              :p => best_score.pushes, :m => best_score.moves)
                                       .where('created_at < ?', best_score.created_at)
                                       .order('pushes ASC, moves ASC, created_at DESC')

      friends_lower_scores = self.level.best_scores
                                       .where(:user_id => self.user.friends.registred.pluck('users.id'))
                                       .where('pushes > :p or (pushes = :p and moves > :m)',
                                              :p => self.pushes, :m => self.moves)

      if old_best_score.empty?
        friends_to_notify = friends_lower_scores.collect { |score| score.user }
      else
        friends_to_notify = friends_lower_scores.where('pushes < :p or (pushes = :p and moves < :m)',
                                                       :p => old_best_score.first.pushes,
                                                       :m => old_best_score.first.moves)
                                                .collect { |score| score.user }
      end

      oauth        = Koala::Facebook::OAuth.new(ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'])
      access_token = oauth.get_app_access_token
      graph        = Koala::Facebook::API.new(access_token)

      friends_to_notify.each do |friend|
        Rails.logger.info("FRIEND : #{friend.name}")
        begin
          graph.put_connections(friend.f_id, "notifications",
                                :template => "@[#{self.user.f_id}] has just beat your score on level '#{self.level.name}', get revenge!",
                                :href     => "?level_id=#{self.level.id}")
        rescue
          Rails.logger.info("NOTIFICATION FAILED FOR #{friend.name}")
        end
      end
    end
  end

  def update_stats
    self.tag_best_score
    PackUserLink.find_or_create_by_pack_id_and_user_id(self.level.pack_id, self.user_id).update_stats
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
        Rails.logger.info("EMPTY")
        LevelUserLink.where('id != ?', self.id).where(:user_id => self.user_id, :level_id => self.level_id).each do |score|
          Rails.logger.info("update false")
          score.update_attributes!({ :best_level_user_score => false })
        end
        self.update_attributes!({ :best_level_user_score => true })
      else
        Rails.logger.info("ELSE")
        self.update_attributes!({ :best_level_user_score => false })
      end
    end
  end

  def ladder_friends(num_of_scores)
    ladder = self.level.best_scores.where(:user_id => self.user.friends + [self.user.id]).all
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

    ladder[start_index..end_index].each do |score|
      score.position = ladder.index(score) + 1
      score
    end
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
