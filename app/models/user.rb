require 'net/https'

class User < ActiveRecord::Base
  extend FriendlyId

  friendly_id :name, :use => :slugged

  # Constants

  DAYS_BEFORE_UPDATING_FRIENDS        = 5
  DAYS_WITHOUT_ADS_IF_FRIENDS_INVITED = 7
  DAYS_WITHOUT_FRIENDS_INVITE_POPUP   = 7

  # Attributes
  attr_protected :created_at, :updated_at

  # Associations
  has_many :user_user_links,
           :primary_key => :f_id

  has_many :friends,
           :through => :user_user_links

  has_many :scores,
           :class_name => 'LevelUserLink'

  has_many :best_scores,
           :class_name => 'LevelUserLink',
           :conditions => { :best_level_user_score => true }

  has_many :levels,
           :through => :scores

  has_many :pack_user_links

  # Nested attributes

  # Validations
  validates :f_id, :uniqueness => true

  # Callbacks

  # Scopes

  def self.registered
    where('email IS NOT NULL')
  end

  def self.not_registered
    where('email IS NULL')
  end

  # Methods

  def self.update_or_create(credentials)
    token = credentials['token']
    graph = Koala::Facebook::API.new(token)
    profile = graph.get_object('me')

    # Debug
    File.open("tmp/#{profile['id']}-#{Time.now.day}-#{Time.now.month}-#{Time.now.year}.yml", "w") do |file|
      file.write profile.to_yaml
    end

    # Admin get an extended token for the fan page publications
    if profile['id'] == ENV['FACEBOOK_ADMIN_ID']
      token = extended_token(token)
      expires_at = Time.now.to_datetime + 60.days
    else
      expires_at = Time.at(credentials['expires_at']).to_datetime
    end

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
      :f_expires_at   => expires_at
    }

    # if user exists, find it and update values (but don't save now)
    # else create user
    user = User.where(:f_id => profile['id'])
    if not user.empty?
      user = user.first
      new_registered_user = (not user.email) ? true : false
      user.attributes = user_hash
    else
      new_registered_user = true
      user = User.new(user_hash)
    end

    if new_registered_user
      # Subscription to mailing list
      mimi = MadMimi.new(ENV['MADMIMI_EMAIL'], ENV['MADMIMI_KEY'])
      mimi.csv_import("email, first name, last name, full name, gender, locale\n" +
                      "#{user.email}, #{user.f_first_name}, #{user.f_last_name}, #{user.name}, #{user.gender}, #{user.locale}")
      mimi.add_to_list(user.email, ENV['MADMIMI_LIST'])

      user.update_attributes!({ :registered_at   => Time.now })
      user.update_attributes!({ :next_mailing_at => Time.now + 7.days })

      # email to admin
      UserNotifier.delay.new_user(user.id)

      # Post status on facebook page if %100
      if (User.registered.count+1) % 100 == 0
        FacebookFeedService.delay.publish_user_count(User.registered.count+1)
      end
    end

    # Facebook bug : sometimes the email is empty => investigate !
    user.email = "#{user.f_username}@facebook.com" if not user.email or user.email.empty?

    user.like_fan_page = user.request_like_fan_page?
    user.update_friends_count

    user
  end

  def registered?
    self.email != nil
  end

  def admin?
    self.f_id == ENV['FACEBOOK_ADMIN_ID'].to_i
  end

  # Ask facebook if this user likes the facebook fan page of the application
  # return true or false
  def request_like_fan_page?
    Rails.logger.info("TOKEN : #{self.f_token}")
    oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'])
    graph = Koala::Facebook::API.new(self.f_token)
    data  = graph.get_connections(self.f_id, "likes/#{ENV['FACEBOOK_PAGE_ID']}")

    found = false
    data.each do |like|
      found = true if like['id'] == "#{ENV['FACEBOOK_PAGE_ID']}"
    end
    return found
  end

  # If new user (no friends) or existing user and old update
  def has_to_build_friendships?
    if not self.friends_updated_at
      true
    elsif Time.now.to_date - self.friends_updated_at.to_date > DAYS_BEFORE_UPDATING_FRIENDS
      true
    else
      false
    end
  end

  # create new user for each friend and link it
  def build_friendships
    graph = Koala::Facebook::API.new(self.f_token)
    friends = graph.get_connections('me', 'friends')

    # update users and user_user_link relation
    friends.each do |friend|
      user = User.find_or_create_by_f_id(friend['id'])
      user.update_attributes!({ :name => friend['name'] })
      user.update_friends_count
      self.user_user_links.find_or_create_by_user_id_and_friend_id(self.f_id, user.f_id)
    end

    # delete user_user_link is not facebook friend anymore
    friend_ids = friends.collect{ |friend| friend['id'] }
    self.user_user_links.where('user_user_links.friend_id not in (?)', friend_ids).destroy_all

    self.update_attributes!({ :friends_updated_at => Time.now })
  end

  def profile_picture(size = "square")
    arg = (size.is_a? Integer) ? "width=#{size}" : "type=#{size}"
    "https://graph.facebook.com/#{self.f_id}/picture?#{arg}"
  end

  # list of subscribed friends, user NOT INCLUDED, sorted by won levels (relative to one pack)
  def subscribed_friends(pack)
    friends = self.friends.registered.all
    join_users_to_pack_user_links_and_sort(friends, pack)
  end

  # list of subscribed friends, user INCLUDED, sorted by won levels (relative to one pack)
  def subscribed_friends_and_me(pack)
    friends = self.friends.registered.all + [self]
    join_users_to_pack_user_links_and_sort(friends, pack)
  end

  # n random popular friends
  # algo to maximize the selection of the people (registered or not) with a lot of registered friends
  # statisticaly we will select half the time a registered friend
  def popular_friends(n)
    registered_friends     = self.friends.registered.all
    not_registered_friends = self.friends.not_registered.order('friends_count DESC').limit(50).all
    popular_friends = []

    # array of friends of registered and not registered friends
    # [3, 55, 34, ...] means that first friend has 3 friends, second friend has 55 friends etc.
    friends_of_rf  = registered_friends.collect { |friend| friend.friends_count }
    friends_of_nrf = not_registered_friends.collect { |friend| friend.friends_count }

    # sum of the array of friends of registered and not registered friends
    # (in an array so we can later pass it by reference and get updated)
    sum_friends_of_rf  = [friends_of_rf.sum]
    sum_friends_of_nrf = [friends_of_nrf.sum]

    while popular_friends.size < n and (sum_friends_of_rf[0] != 0 or sum_friends_of_nrf[0] != 0)
      choice = rand(1..6)
      # select a registered popular friend
      if choice == 1 and sum_friends_of_rf[0] != 0
        popular_friends << select_one_user(registered_friends, friends_of_rf, sum_friends_of_rf)
      # select a not registered popular friend
      elsif choice.in? [2, 3, 4, 5, 6] and sum_friends_of_nrf[0] != 0
        popular_friends << select_one_user(not_registered_friends, friends_of_nrf, sum_friends_of_nrf)
      end
    end

    return popular_friends
  end

  def display_advertisement?
    if self.full_game
      false
    else
      Time.now >= self.send_invitations_at + DAYS_WITHOUT_ADS_IF_FRIENDS_INVITED.days.to_i
    end
  end

  def display_friends_invite_popup?
    if self.full_game
      false
    else
      Time.now >= self.send_invitations_at + DAYS_WITHOUT_FRIENDS_INVITE_POPUP.days.to_i
    end
  end

  # update friends count (friends that are on the database : registered or not)
  def update_friends_count
    # registered user of not registered user
    if self.email
      self.update_attributes!({ :friends_count => self.friends.count })
    else
      self.update_attributes!({ :friends_count => UserUserLink.where(:friend_id => self.f_id).count })
    end
  end

  def unsubscribe_from_mailing
    mimi = MadMimi.new(ENV['MADMIMI_EMAIL'], ENV['MADMIMI_KEY'])
    mimi.remove_from_list(self.email, ENV['MADMIMI_LIST'])
    self.update_attributes!({ :mailing_unsubscribe => true })
  end

  def ladder_positions
    if self.total_won_levels == 0
      { :top_friends_position => self.friends.registered.count + 1,
        :top_users_position   => User.registered.count }
    else
      { :top_friends_position => self.friends.registered.where('total_won_levels > ?', self.total_won_levels).count + 1,
        :top_users_position   => User.registered.where('total_won_levels > ?', self.total_won_levels).count + 1 }
    end
  end

  def ladder
    self.ladder_positions.merge({
      :top_friends          => (self.friends.registered.all + [self]).sort_by(&:total_won_levels).reverse,
      :top_users            => User.registered.order('total_won_levels DESC').limit(50)
    })
  end

  private

  # extend short token (2 hours) to long expiration token (min 60 days).
  # Usefull to use the admin user to post on facebook fan page
  # cf. https://developers.facebook.com/roadmap/offline-access-removal/
  def self.extended_token(token)
    url = "https://graph.facebook.com/oauth/access_token?client_id=#{ENV['FACEBOOK_APP_ID']}&client_secret=#{ENV['FACEBOOK_APP_SECRET']}&grant_type=fb_exchange_token&fb_exchange_token=#{token}"
    url = URI.parse(url)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    token = https.request_get(url.path + '?' + url.query).body
    token.split('&').collect {|params| params.split('=')}.keep_if { |param| param.first == 'access_token' }.first.second
  end

  # select one random user depending on the common number of friends (the more friends, the more the chance to be selected)
  # users               : array of users [steve_object, paul_object, marc_object]
  # users_friends_count : array of friends num for each of these users [34,11,55] (steve has 34 friends)
  # total_user_friends  : sum of users_friends_count. ATTENTION : in an array ! (here : [100])
  # --> return user and update entry values
  def select_one_user(users, users_friends_count, total_user_friends)
    selected_user = nil
    rand_number = rand(total_user_friends[0])
    users_friends_count.each_with_index do |friends_count, index|
      if rand_number <= friends_count
        selected_user = users[index]
        # remove this user of the list
        total_user_friends[0] = total_user_friends[0] - friends_count
        users.delete_at(index)
        users_friends_count.delete_at(index)
        break
      else
        rand_number = rand_number - friends_count
      end
    end

    return selected_user
  end

  def join_users_to_pack_user_links_and_sort(friends, pack)
    friend_ids = friends.collect(&:id)
    friends_in_the_pack = User.where(:id => friend_ids)
                              .select('users.*, pack_user_links.*')
                              .joins(:pack_user_links).where('pack_user_links.pack_id = ?', pack.id)
                              .sort { |x,y| [y.won_levels_count, y.total_won_levels] <=> [x.won_levels_count, x.total_won_levels] }
    friends_in_the_pack_ids = friends_in_the_pack.collect { |user| user.user_id }

    friends_not_in_the_pack = []
    friends.each do |friend|
      if not friend.id.in? friends_in_the_pack_ids
        friends_not_in_the_pack << friend
      end
    end

    friends_not_in_the_pack.sort! { |x,y| y.total_won_levels <=> x.total_won_levels }
    friends_in_the_pack + friends_not_in_the_pack
  end
end
