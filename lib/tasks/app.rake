namespace :app  do
  task :reset => :environment do
    if Rails.env.production?
      puts "Cannot use this task in production"
    else
      system('rake db:migrate:reset')
      system('rake db:seed')
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
end

