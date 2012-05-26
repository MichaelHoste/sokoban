# compile coffee file that will be loaded by the server in javascript 
# to reuse the level methods in ruby
def compile_coffee_to_js
  `rm -f lib/assets/level_core.js lib/assets/level_core.js.js`
  `rm -f lib/assets/path_core.js lib/assets/path_core.js.js`
  
  `coffee --compile --output lib/assets/ app/assets/jax/models/level_core.js.coffee`
  `coffee --compile --output lib/assets/ app/assets/jax/models/path_core.js.coffee`
  
  `mv lib/assets/level_core.js.js lib/assets/level_core.js`
  `mv lib/assets/path_core.js.js lib/assets/path_core.js`
  
end

namespace :app  do
  task :reset => :environment do
    if Rails.env.production?
      puts "Cannot use this task in production"
    else
      compile_coffee_to_js()
      Rake::Task['db:migrate:reset'].invoke
      Rake::Task['db:seed'].invoke
    end
  end
  
  # compile core class from coffeescript to javascript to be used with ruby
  task :compile_coffee => :environment do
    if Rails.env.production?
      puts "Cannot use this task in production"
    else
      compile_coffee_to_js()
    end
  end
  
  task :deploy => :environment do
    if Rails.env.production?
      puts "Cannot use this task in production"
    else
      compile_coffee_to_js()
      # generate right gemfile for production and deploy to server
      `export MY_BUNDLE_ENV='production'`
      `bundle update`
      `bundle install`
      `git add .`
      `git commit -a -m "gemfile"`
      `git push heroku master`
      `heroku run db:migrate`
      `heroku restart`
      
      # generate right gemfile for development and save to github
      `export MY_BUNDLE_ENV='development'`
      `bundle update`
      `bundle install`
      `git add .`
      `git commit -a -m "gemfile"`
      `git push heroku master`    end
  endend
