class User < ActiveRecord::Base
  
  # Constants
  
  # Attributes
  attr_protected :created_at, :updated_at
  
  # Associations
  has_many :user_user_links,
           :primary_key => :f_id
           
  has_many :friends,
           :through => :user_user_links
           
  has_many :scores,
           :class_name => 'LevelUserLinks'
           
  has_many :levels,
           :through => :scores
             
  # Nested attributes
  
  # Validations
  validates :f_id, :uniqueness => true
  
  # Callbacks
  
  # Methods
  
  def self.update_or_create(credentials)
    token = credentials['token']
    graph = Koala::Facebook::API.new(token)
    profile = graph.get_object('me')
    
    # Hash with user values
    user_hash = {
      :name => profile['name'],
      :email => profile['email'],
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
      user
    else
      User.new(user_hash)
    end
  end
  
  # create new user for each friend and link it
  def build_friendships
    graph = Koala::Facebook::API.new(self.f_token)
    friends = graph.get_connections('me', 'friends')
    
    # delete each friend relation of user (in user_user_link)
    self.user_user_links.destroy_all
    
    # update users and user_user_link relation
    friends.each do |friend|
      user_hash = { :f_id => friend['id'], :name => friend['name'] }
      user = User.where(:f_id => friend['id'])
      if not user.empty?
        user = user.first
        user.attributes = user_hash
      else
        user = User.create!(user_hash)
      end
      
      Rails.logger.info("USER : " + user.to_s)
      
      self.user_user_links << UserUserLink.new(:user_id => self.f_id, :friend_id => user.f_id)
      self.save!
    end
  end
end
