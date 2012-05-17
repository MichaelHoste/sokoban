class User < ActiveRecord::Base
  
  # Constants
  
  # Attributes
  attr_protected :created_at, :updated_at
  
  # Associations
  has_many :friends,
           :primary_key => :f_id,
           :through => :user_user_links
  
  # Nested attributes
  
  # Validations
  validates :f_id, :uniqueness => true
  
  # Callbacks
  
  # Methods
  
  def self.find_or_create(credentials)
    token = credentials['token']
    graph = Koala::Facebook::API.new(token)
    profile = graph.get_object('me')
    
    # Hash with user values
    user_hash = {
      :name => profile['name'],
      :picture => graph.get_picture('me'),
      :gender => profile['gender'],
      :locale => profile['locale'],
      :f_id => profile['id'],
      :f_token => token,
      :f_first_name => profile['first_name'],
      :f_middle_name => profile['middle_name'],
      :f_last_name => profile['last_name'],
      :f_username => profile['username'],
      :f_link => profile['link'],
      :f_timezone => profile['timezone'],
      :f_updated_time => profile['updated_time'],
      :f_verified => profile['verified'],
      :f_expires => credentials['expires'],
      :f_expires_at => Time.at(credentials['expires_at']).to_datetime
    }
    
    # if user exists, find it and update values (but don't save now)
    # else create user
    user = User.where(:f_id => profile['id'])
    if not user.empty?
      user = user.first
      user.attributes = user_hash
      Rails.logger.info("UPDATED")
      user
    else
      Rails.logger.info("CREATED")
      User.new(user_hash)
    end
  end
end
