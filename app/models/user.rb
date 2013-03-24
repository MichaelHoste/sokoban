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
           :class_name => 'LevelUserLink',
           :order      => 'pushes ASC, moves ASC, created_at DESC'

  has_many :best_scores,
           :class_name => 'LevelUserLink',
           :order      => 'pushes ASC, moves ASC, created_at DESC',
           :conditions => { :best_level_user_score => true }

  has_many :levels,
           :through => :scores

  # Nested attributes

  # Validations
  validates :f_id, :uniqueness => true

  # Callbacks
  before_save :update_friends_count

  # Scopes

  def self.registred
    where('email IS NOT NULL')
  end

  def self.not_registred
    where('email IS NULL')
  end

  # Methods

  def self.update_or_create(credentials)
    token = credentials['token']
    graph = Koala::Facebook::API.new(token)
    profile = graph.get_object('me')

    # Hash with user values
    user_hash = {
      :name           => profile['name'],
      :email          => profile['email'],
      :picture        => graph.get_picture('me'),
      :gender         => profile['gender'],
      :locale         => profile['locale'],
      :f_id           => profile['id'],
      :f_token        => token,
      :f_first_name   => profile['first_name'],
      :f_middle_name  => profile['middle_name'],
      :f_last_name    => profile['last_name'],
      :f_username     => profile['username'],
      :f_link         => profile['link'],
      :f_timezone     => profile['timezone'],
      :f_updated_time => profile['updated_time'],
      :f_verified     => profile['verified'],
      :f_expires      => credentials['expires'],
      :f_expires_at   => Time.at(credentials['expires_at']).to_datetime
    }

    # if user exists, find it and update values (but don't save now)
    # else create user
    user = User.where(:f_id => profile['id'])
    if not user.empty?
      user = user.first
      user.attributes = user_hash
    else
      user = User.new(user_hash)

      mimi = MadMimi.new(ENV['MADMIMI_EMAIL'], ENV['MADMIMI_KEY'])
      mimi.csv_import("email, first name, last name, full name, gender, locale\n" +
                      "#{user.email}, #{user.f_first_name}, #{user.f_last_name}, #{user.name}, #{user.gender}, #{user.locale}")
      mimi.add_to_list(user.email, 'Sokoban')
    end
    user
  end

  def registred?
    self.email != nil
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
    friends = self.friends.registred.all
    friends.sort {|x,y| y.won_levels_count(pack) <=> x.won_levels_count(pack) }
  end

  # list of subscribed friends, user INCLUDED, sorted by won levels (relative to packs or all)
  def subscribed_friends_and_me(pack=nil)
    friends = self.friends.registred.all
    friends << self
    friends.sort {|x,y| y.won_levels_count(pack) <=> x.won_levels_count(pack) }
  end

  def subscribed_friends_ids
    self.friends.registred.pluck(:f_id)
  end

  # n random popular friends
  # algo to maximize the selection of the people (registred or not) with a lot of registred friends
  # statisticaly we will select half the time a registred friend
  def popular_friends(n)
    registred_friends = self.friends.registred.all
    not_registred_friends = self.friends.not_registred.all
    popular_friends = []

    # array of friends of registred and not registred friends
    # [3, 55, 34, ...] means that first friend has 3 friends, second friend has 55 friends etc.
    friends_of_rf  = registred_friends.collect { |friend| friend.friends_count }
    friends_of_nrf = not_registred_friends.collect { |friend| friend.friends_count }

    # sum of the array of friends of registred and not registred friends
    # (in an array so we can later pass it by reference)
    sum_friends_of_rf  = [friends_of_rf.sum]
    sum_friends_of_nrf = [friends_of_nrf.sum]

    while popular_friends.size < n and (sum_friends_of_rf[0] != 0 or sum_friends_of_nrf[0] != 0)
      choice = rand(1..2)
      # select a registred popular friend
      if choice == 1 and sum_friends_of_rf[0]  != 0
        popular_friends << select_one_user(registred_friends, friends_of_rf, sum_friends_of_rf)
      # select an not registred popular friend
      elsif choice == 2 and sum_friends_of_nrf[0] != 0
        popular_friends << select_one_user(not_registred_friends, friends_of_nrf, sum_friends_of_nrf)
      end
    end

    return popular_friends
  end

  # list of won level ids (from the selected pack of for all packs) for this user
  def won_levels_list(pack=nil)
    if pack
      pack.won_levels_list(self)
    else
      Pack.won_levels_list(self)
    end
  end

  def won_levels_count(pack=nil)
    if pack
      levels_ids = pack.levels.pluck(:id)
      self.best_scores.where(:level_id => levels_ids).count
    else
      self.best_scores.count
    end
  end

  private

  # update (bi-directional) friends count (friends that are on the database : registred or not)
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

  # select one random user depending on the common number of friends (the more friends, the more the chance to be selected)
  # users : array of users [steve_object, paul_object, marc_object]
  # users_friends_count : array of friends num for each of these users [34,11,55] (steve has 34 friends)
  # total_user_friends : sum of users_friends_count. ATTENTION : in an array ! (here : [100])
  def select_one_user(users, users_friends_count, total_user_friends)
    selected_user = nil
    rand_number = rand(total_user_friends[0])
    users_friends_count.each_with_index do |friends_count, index|
      if rand_number <= friends_count
        selected_user = users[index]
        # remove this user of the list
        total_user_friends[0] = total_user_friends[0] - users_friends_count[index]
        users.delete_at(index)
        users_friends_count.delete_at(index)
        break
      else
        rand_number = rand_number - friends_count
      end
    end

    return selected_user
  end
end
