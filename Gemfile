source 'https://rubygems.org'

ruby '2.6.5' # ensure consistency with .ruby-version!
             # IF BUMPING RUBY VERSION, EXECUTE 'gem install backup -v5.0.0.beta.2'
             # ON SERVER AFTER BUMP!

# Rails
gem 'rails', '6.0.4.6'
gem 'mysql2'

# Assets
gem 'sass-rails'
gem 'uglifier',     '>= 1.3.0'
gem 'coffee-rails', '~> 4.0'
gem 'bootsnap',     '1.7.2', :require => false

gem 'omniauth-facebook', '4.0.0'
gem 'koala'
gem 'nokogiri'
gem 'madmimi'
gem 'delayed_job_active_record'
gem 'daemons' # for delayed job
gem 'sitemap_generator'
gem 'httparty'
gem 'friendly_id'
gem 'rabl'
gem 'non-stupid-digest-assets' # to have non-digested assets
gem 'bugsnag'

# Stats
gem 'newrelic_rpm'

# Graphs
gem 'groupdate'
gem 'chartkick', '3.4.0'

# Translation
gem 'gettext_i18n_rails'

# Cache
gem 'dalli'

gem 'jquery-rails'
#gem 'therubyracer'  # Exec js code in ruby

# Development tools
group :development do
  gem 'puma'
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger', '0.0.2'

  gem 'listen', '3.5.1' # for EventedFileUpdateChecker

  gem 'web-console'

  #gem 'active_record_query_trace' # pour voir où dans le code sont appelées les requetes SQL
end

# Production/deployment tools
group :production do
  gem 'whenever'
  #gem 'backup'      # Install on server: http://backup.github.io/backup/v4/storage-dropbox/
  #gem 'dropbox-sdk'
end
