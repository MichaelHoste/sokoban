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
           :class_name => 'LevelUserLink'
           
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
            
      self.user_user_links << UserUserLink.new(:user_id => self.f_id, :friend_id => user.f_id)
      self.save!
    end
  end
  
  def profile_picture
    if self.picture
      self.picture
    else
      graph = Koala::Facebook::API.new
      self.picture = graph.get_picture(self.f_id, :type => 'square')
    end
  end

  def subscribed_friends
    self.friends.where('email IS NOT NULL')
  end
  
  def subscribed_friends_ids
    self.friends.where('email IS NOT NULL').pluck(:f_id)
  end
  
  # list of won level ids (from the selected pack of for all packs) for this user
  def won_levels_ids(pack)
    if pack
      pack.won_levels_ids(self)
    else
      Pack.won_levels_ids(self)
    end
  end
  
  def won_levels_count(pack)
    if pack
      levels_ids = pack.levels.pluck(:id)
      self.scores.where(:level_id => levels_ids).uniq.count
    else
      self.scores.pluck(:level_id).uniq.count
    end
  end
end
