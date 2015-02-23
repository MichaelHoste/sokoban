source 'https://rubygems.org'

gem 'rails',   '3.2.12'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'
gem 'json'
gem 'omniauth-facebook', '1.4.0' # because of this in 1.4.1 : https://github.com/mkdynamic/omniauth-facebook/issues/73
gem 'koala'
gem 'nokogiri'
gem 'madmimi'
gem 'delayed_job_active_record'
gem 'daemons' # for delayed job
gem 'sitemap_generator'
gem 'httparty'
gem 'friendly_id'
gem 'rabl'
gem 'SyslogLogger'

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

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
end

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
