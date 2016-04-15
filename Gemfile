source 'https://rubygems.org'

# Rails
gem 'rails', '4.2.5.1'
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

# Stats
gem 'newrelic_rpm'

# Deployement
gem 'capistrano'
gem 'foreman'

# Graphs
gem 'groupdate'
gem 'chartkick'

# Translation
gem 'gettext_i18n_rails'

# Cache
gem 'dalli'
gem 'kgio' # 20-30% boost for memcached

gem 'jquery-rails'
gem 'therubyracer'  # Exec js code in ruby
gem 'libv8'

# Development tools
group :development do
  gem 'thin'
  gem 'quiet_assets'
  gem 'query_reviewer'

  # translation
  gem 'gettext',     :require => false # use "brew link --force gettext" to link to gettext on MacOS (brew was afraid to link)
  gem 'ruby_parser', :require => false
end

# Production/deployment tools
group :production do
  gem 'unicorn'
  gem 'airbrake'
  gem 'whenever',    :require => false
  gem 'backup',      :require => false
  gem 'dropbox-sdk', :require => false
end
