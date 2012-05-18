class Level < ActiveRecord::Base

  # Constants
  
  # Attributes
  attr_protected :created_at, :updated_at
  
  # Associations
  belongs_to :pack
  
  # Nested attributes
  
  # Validations
  
  # Callbacks
  
  # Methods
  def self.populate
    cxt = V8::Context.new
    cxt.load('public/assets/jax/application.js')
    #Rails.logger.info("CIICI: " + cxt.eval('Level.find("actual")'))
  end

end
