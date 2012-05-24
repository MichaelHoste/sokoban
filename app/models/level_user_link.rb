require 'v8'

class ValidatePath < ActiveModel::Validator
  # path is a uncompressed string
  def validate(score)
    path = score.uncompressed_path
    level = Level.find(score.level_id)
    is_won = false
    
    V8::C::Locker() do
      V8::Context.new do |cxt|
        Rails.logger.info("A")
        cxt.eval('var window = new Object')
        cxt.load('lib/assets/path_core.js')
        cxt.load('lib/assets/level_core.js')
        
        cxt.eval('var path = new window.PathCore()')
        cxt.eval("path.create_from_uncompressed('#{path}')")
                
        cxt.eval('var level = new window.LevelCore()')
        cxt.eval("level.create_from_line('#{level.inline_grid}', #{level.width}, #{level.height}, '', '')")
        
        is_won = cxt.eval('level.is_solution_path(path)')
        Rails.logger.info("B - #{is_won}")
      end
    end
    
    return true
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
  
  # Nested attributes
  
  # Validations

  validates_with ValidatePath

  validates :user_id, :level_id, :uncompressed_path, :compressed_path, :pushes, :moves,
            :presence => true
              
  # Callbacks

  before_validation :populate_and_validate_score
  
  # Methods

  def populate_and_validate_score
    generate_paths(self.path)
    generate_pushes_and_moves()
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
    V8::C::Locker() do
      V8::Context.new do |cxt|
        cxt.eval('var window = new Object')
        cxt.load('lib/assets/path_core.js')
        cxt.eval('var path = new window.PathCore()')
        cxt.eval("path.create_from_uncompressed('#{path}')")
        compressed_path = cxt.eval("path.get_compressed_string_path()")
        Rails.logger.info("COMPRESSED PATH 1 " + compressed_path.to_s)
      end
    end
    Rails.logger.info("COMPRESSED PATH 2 " + compressed_path.to_s)
    
    compressed_path
  end
  
  # uncompres path
  def uncompress_path(path)
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
end
