module FacebookFeedService
  def self.delayed_publish_random_level
    jobs = Delayed::Job.where(:queue => 'publish_random_level')

    if jobs.count > 1
      jobs.destroy_all
      jobs = []
    end

    if not jobs.empty?
      FacebookFeedService.delay(:run_at => jobs.first.run_at, :queue => 'publish_random_level').publish_random_level
      jobs.first.destroy
    else
      FacebookFeedService.delay(:run_at => rand(18..24).hours.from_now, :queue => 'publish_random_level').publish_random_level
    end
  end

  def self.publish_random_level
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

    page = Koala::Facebook::API.new(FacebookFeedService.get_page_access_token)
    page.put_connections(ENV['FACEBOOK_PAGE_ID'], 'feed',
      { :message     => message,
        :link        => "http://sokoban.be" +  Rails.application.routes.url_helpers.pack_level_path(level.pack.name, level.name),
        :name        => "#{level.name}",
        :description => "Pack : #{level.pack.name.gsub(/\n/," ").gsub(/\r/," ")} | #{level.pack.description.gsub(/\n/," ").gsub(/\r/," ")}",
        :picture     => level.thumb,
        :type        => "sokoban_game:level" })
  end

  def self.publish_level_count(count)
    level = LevelUserLink.order('id DESC').first.level

    message = "The users of Sokoban solved #{count} levels. Keep up the good work!"

    page = Koala::Facebook::API.new(FacebookFeedService.get_page_access_token)
    page.put_connections(ENV['FACEBOOK_PAGE_ID'], 'feed',
      { :message     => message,
        :link        => "http://sokoban.be" +  Rails.application.routes.url_helpers.pack_level_path(level.pack.name, level.name),
        :name        => "Last level to get solved : #{level.name}",
        :description => "Pack : #{level.pack.name.gsub(/\n/," ").gsub(/\r/," ")} | #{level.pack.description.gsub(/\n/," ").gsub(/\r/," ")}",
        :picture     => level.thumb,
        :type        => "sokoban_game:level" })
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

