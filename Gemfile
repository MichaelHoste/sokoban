source 'https://rubygems.org'

# Rails
gem 'rails', '4.2.11.1'
gem 'mysql2'

# Assets
gem 'sass-rails',   '~> 5.0'
gem 'uglifier',     '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'

gem 'omniauth-facebook'
gem 'koala'
gem 'nokogiri'
gem 'madmimi'
gem 'delayed_job_active_record'
gem 'daemons' # for delayed job
gem 'sitemap_generator'
gem 'httparty'
gem 'friendly_id'
gem 'rabl'
gem 'protected_attributes'     # TODO remove this and use strong_params
gem "non-stupid-digest-assets" # to have non-digested assets

# Stats
gem 'newrelic_rpm'

# Graphs
gem 'groupdate'
gem 'chartkick'

# Translation
gem 'gettext_i18n_rails'

# Cache
gem 'dalli'
gem 'kgio' # 20-30% boost for memcached

gem 'jquery-rails'
#gem 'therubyracer'  # Exec js code in ruby

# Development tools
group :development do
  gem 'thin'

  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger', '0.0.2'

  gem 'web-console', '~> 2.0'

  #gem 'active_record_query_trace' # pour voir où dans le code sont appelées les requetes SQL
end

# Production/deployment tools
group :production do
  gem 'airbrake',    '4.3.5'
  gem 'whenever'
  #gem 'backup'      # Install on server: http://backup.github.io/backup/v4/storage-dropbox/
  #gem 'dropbox-sdk'
end
