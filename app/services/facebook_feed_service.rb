module FacebookFeedService
  def self.delayed_publish_random_level
    Delayed::Job.where(:queue => 'publish_random_level').destroy_all
    FacebookFeedService.delay(:run_at => rand(24..48).hours.from_now, :queue => 'publish_random_level').publish_random_level(true)
  end

  def self.publish_random_level(repeat = false)
    number = rand(1..2)
    if number == 1
      level = Level.complexity_random(nil, 600)
    else
      level = Level.users_random(nil, 600)
    end

    # publish on feed
    count_won = level.best_scores.count
    if count_won == 0
      message = "Be the first to solve this level!"
    elsif count_won == 1
      message = "One person already solved this level. Can you do the same?"
    else
      message = "#{count_won} people already solved this level. Can you do the same?"
    end

    begin
      page = Koala::Facebook::API.new(FacebookFeedService.get_page_access_token)
      page.put_connections(ENV['FACEBOOK_PAGE_ID'], 'feed',
        { :message     => message,
          :link        => "https://sokoban-game.com" +  Rails.application.routes.url_helpers.pack_level_path(level.pack, level),
          :name        => "Level of the day : #{level.name}",
          :description => "Pack : #{level.pack.name.gsub(/\n/," ").gsub(/\r/," ")} | #{level.pack.description.gsub(/\n/," ").gsub(/\r/," ")}",
          :picture     => level.thumb,
          :type        => "sokoban_game:level" }) if Rails.env.production?
    rescue Koala::Facebook::APIError => e
      Rails.logger.info("PUBLISH RANDOM LEVEL FAILED (but was published anyway ?)")
    end

    if repeat
      FacebookFeedService.delayed_publish_random_level
    end
  end

  def self.publish_level_count(count)
    level = LevelUserLink.order('id DESC').first.level

    random = rand(3)
    if random == 0
      message = "The users of Sokoban solved #{count} levels. Keep up the good work!"
    elsif random == 1
      message = "You already solved #{count} levels. Thank you all !"
    else
      message = "You already solved #{count} levels !"
    end

    begin
      page = Koala::Facebook::API.new(FacebookFeedService.get_page_access_token)
      page.put_connections(ENV['FACEBOOK_PAGE_ID'], 'feed',
        { :message     => message,
          :link        => "https://sokoban-game.com" +  Rails.application.routes.url_helpers.pack_level_path(level.pack, level),
          :name        => "Last level to get solved : #{level.name}",
          :description => "Pack : #{level.pack.name.gsub(/\n/," ").gsub(/\r/," ")} | #{level.pack.description.gsub(/\n/," ").gsub(/\r/," ")}",
          :picture     => level.thumb,
          :type        => "sokoban_game:level" }) if Rails.env.production?
    rescue Koala::Facebook::APIError => e
      Rails.logger.info("PUBLISH LEVEL COUNT FAILED (but was published anyway ?)")
    end
  end

  def self.publish_user_count(count)
    level = LevelUserLink.order('id DESC').first.level

    level_count = LevelUserLink.count
    message = "#{count} users are registered on Sokoban with an average of #{(level_count.to_f/count.to_f).round} levels solved by user!"

    begin
      page = Koala::Facebook::API.new(FacebookFeedService.get_page_access_token)
      page.put_connections(ENV['FACEBOOK_PAGE_ID'], 'feed',
        { :message     => message,
          :link        => "https://sokoban-game.com" +  Rails.application.routes.url_helpers.pack_level_path(level.pack, level),
          :name        => "Last level to get solved : #{level.name}",
          :description => "Pack : #{level.pack.name.gsub(/\n/," ").gsub(/\r/," ")} | #{level.pack.description.gsub(/\n/," ").gsub(/\r/," ")}",
          :picture     => level.thumb,
          :type        => "sokoban_game:level" }) if Rails.env.production?
    rescue Koala::Facebook::APIError => e
      Rails.logger.info("PUBLISH USER COUNT FAILED (but was published anyway ?)")
    end
  end

  def self.get_page_access_token
    oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'])

    # Get pages accounts of administrator (token of administrator is extended : https://developers.facebook.com/roadmap/offline-access-removal/)
    admin    = User.where(:f_id => ENV['FACEBOOK_ADMIN_ID']).first
    graph    = Koala::Facebook::API.new(admin.f_token)
    accounts = graph.get_connections(ENV['FACEBOOK_ADMIN_ID'], "accounts")

    # Get page token to publish on feed
    page_access_token = ""
    accounts.each do |account|
      if account['id'] == ENV['FACEBOOK_PAGE_ID']
        return account['access_token']
      end
    end

    return nil
  end
end

