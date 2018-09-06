namespace :app  do
  task :reset => :environment do
    if Rails.env.production?
      puts "Cannot use this task in production"
    else
      system('rake db:migrate:reset')
      system('rake db:seed')
    end
  end

  task :update_stats => :environment do
    LevelUserLink.order(:id => :asc).find_each do |level_user_link|
      puts "TAG BEST SCORE #{level_user_link.id}\n"
      level_user_link.tag_best_score
    end

    PackUserLink.order(:id => :asc).find_each do |pack_user_link|
      puts "UPDATE PACK STATS #{pack_user_link.id}\n"
      pack_user_link.update_stats
    end

    Level.order(:id => :asc).find_each do |level|
      puts "UPDATE LEVEL WON_COUNT #{level.id}"
      level.update_attributes!({ :won_count => level.best_scores.count })
    end

    User.registered.order(:id => :asc).find_each do |user|
      puts "UPDATE USER WON_LEVELS_COUNT #{user.id}"
      user.update_attributes!({ :total_won_levels => user.pack_user_links.collect(&:won_levels_count).sum })
      UserUserLink.recompute_counts_for_user(user.id)
    end
  end

  task :facebook_feed_delayed_job => :environment do
    publish_jobs = Delayed::Job.where(:queue => 'publish_random_level')
    if publish_jobs.empty?
      FacebookFeedService.delayed_publish_random_level
    else
      run_at = publish_jobs.first.run_at
      publish_jobs.destroy_all
      FacebookFeedService.delay(:run_at => run_at, :queue => 'publish_random_level').publish_random_level(true)
    end
  end

  task :send_mailing_delayed_job => :environment do
    MailingService.delayed_send_mailing
  end

  task :flush_cache => :environment do
    Rails.cache.clear
  end

  task :delete_user => :environment do
    user = User.where(:email => 'email').first
    # or
    user = User.where(:name => 'name').first

    user.remove_from_application
  end
end

