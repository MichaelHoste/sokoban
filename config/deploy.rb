lock '3.4.1'

set :repo_url, 'git://github.com/MichaelHoste/sokoban.git'
set :keep_releases, 5

set :use_sudo,  false
set :log_level, :debug

set :linked_files, %w{config/database.yml config/email.yml config/newrelic.yml config/backup.rb config/initializers/facebook.rb config/initializers/madmimi.rb config/initializers/errbit.rb}
set :linked_dirs,  %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/images/levels}

set :rbenv_type, 'user'
set :rbenv_path, '/home/deploy/.rbenv/'

set :bundle_binstubs, nil
set :bundle_bins,     %w(gem rake rails delayed_job)

after 'deploy:publishing', 'delayed_job:restart'
after 'deploy:publishing', 'deploy:refresh_sitemap'

# # Launch delayed job for publish feed
# run("cd #{latest_release} && bundle exec rake app:facebook_feed_delayed_job RAILS_ENV=#{rails_env}")

# # Launch delayed job for sending (weekly) mailing list
# run("cd #{latest_release} && bundle exec rake app:send_mailing_delayed_job RAILS_ENV=#{rails_env}")
