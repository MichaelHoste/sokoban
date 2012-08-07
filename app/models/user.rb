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
  before_save :update_friends_count
  
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

  # list of subscribed friends, user NOT INCLUDED, sorted by won levels (relative to packs or all)
  def subscribed_friends(pack=nil)
    friends = self.friends.where('email IS NOT NULL').all
    friends.sort {|x,y| y.won_levels_count(pack) <=> x.won_levels_count(pack) }
  end
  
  # list of subscribed friends, user INCLUDED, sorted by won levels (relative to packs or all)
  def subscribed_friends_and_me(pack=nil)
    friends = self.friends.where('email IS NOT NULL').all
    friends << self
    friends.sort {|x,y| y.won_levels_count(pack) <=> x.won_levels_count(pack) }
  end
  
  def subscribed_friends_ids
    self.friends.where('email IS NOT NULL').pluck(:f_id)
  end
  
  # n random popular friends
  # algo to maximize the selection of the people (registred or not) with a lot of registred friends
  # statisticaly we will select half the time a registred friend
  def popular_friends(n)
    registred_friends = self.friends.where('email IS NOT NULL').all
    not_registred_friends = self.friends.where('email IS NULL').all
    popular_friends = []

    # array of friends of registred and not registred friends
    # [3, 55, 34, ...] means that first friend has 3 friends, second friend has 55 friends etc.
    friends_of_rf  = registred_friends.collect { |friend| friend.friends_count } 
    friends_of_nrf = not_registred_friends.collect { |friend| friend.friends_count } 
        
    sum_friends_of_rf  = friends_of_rf.reduce(:+)
    sum_friends_of_nrf = friends_of_nrf.reduce(:+)
    
    while popular_friends.size < n and sum_friends_of_rf != 0 do
      rand_number = rand(sum_friends_of_rf)
      friends_of_rf.each_with_index do |friends_count, index|
        if rand_number <= friends_count
          popular_friends << registred_friends[index]
          # remove this friend from the list
          registred_friends.delete_at(index)
          friends_of_rf.delete_at(index)
          sum_friends_of_rf = friends_of_rf.reduce(:+)
          break
        else
          rand_number = rand_number - friends_count
        end
      end
    end
    
    return popular_friends
    
#    n.times do
#      if rand(1..2) == 1
#        friends_of_rf
#      else 
#        friends_of_nrf
#      end
#    end
  end
  
  # list of won level ids (from the selected pack of for all packs) for this user
  def won_levels_ids(pack=nil)
    if pack
      pack.won_levels_ids(self)
    else
      Pack.won_levels_ids(self)
    end
  end
  
  def won_levels_count(pack=nil)
    if pack
      levels_ids = pack.levels.pluck(:id)
      self.scores.select('DISTINCT level_id').where(:level_id => levels_ids).count
    else
      self.scores.select('DISTINCT level_id').count
    end
  end
  
  private
  
  # update (bi-directional) friends count
  # cannot be used with simple 'counter_cache' because of non-registred friends 
  # that only are on the 'friend_id' side of the relation
  def update_friends_count
    # registred user of not registred user
    if self.email
      self.friends_count = self.friends.count
    else
      self.friends_count = UserUserLink.where(:friend_id => self.f_id).count
    end
  end
end
