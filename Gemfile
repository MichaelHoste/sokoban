source 'https://rubygems.org'

gem 'rails', '3.2.3'
gem "jax", '3.0.0.rc1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'
gem 'json'
gem 'omniauth-facebook'
gem "koala", "~> 1.5.0"
gem "nokogiri", "~> 1.5.2"   # xml parser
gem 'capistrano'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
end

gem 'jquery-rails'
gem 'therubyracer'  # Exec js code in ruby

# Development tools
group :development do
  gem 'thin'
  gem 'quiet_assets'
# gem 'heroku'
end

# Production/deployment tools
group :production do
  gem 'unicorn'
  gem 'airbrake'
  gem 'whenever',                :require => false
  gem 'backup',                  :require => false
  gem 'dropbox-sdk', '~> 1.2.0', :require => false
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# To use debugger
# gem 'ruby-debug'
