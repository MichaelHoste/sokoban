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

  attr_accessor :path
  attr_protected :created_at, :updated_at
  
  # Associations

  belongs_to :level
  belongs_to :user
  
  # Scope
  default_scope :order => 'pushes ASC, moves ASC, created_at DESC'
  
  # Nested attributes
  
  # Validations

  validates_with ValidatePath

  # user_id can be null for anonymous scores
  validates :level_id, :uncompressed_path, :compressed_path, :pushes, :moves,
            :presence => true
              
  # Callbacks

  before_validation :populate_and_validate_score
  def populate_and_validate_score
    generate_paths(self.path)
    generate_pushes_and_moves()
  end
  
  # Methods
  
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
  
  # global ranking of this score
  def global_ranking
    LevelUserLink.select(:user_id)
#                 .uniq
                 .where('user_id != ?', self.user_id) # not the user himself
                 .where('pushes < ? OR (pushes = ? AND moves < ?)', self.pushes, self.pushes, self.moves)
                 .all.uniq.count + 1
  end
  
  # friends ranking of this score
  def friends_ranking
    if self.user != nil
      LevelUserLink.select(:user_id)
 #                  .uniq
                   .where(:user_id => self.user.friends.select(:user_id).where('email IS NOT NULL'))
                   .where('pushes < ? OR (pushes = ? AND moves < ?)', self.pushes, self.pushes, self.moves)
                   .all.uniq.count + 1
    else
      0
    end
  end
end
