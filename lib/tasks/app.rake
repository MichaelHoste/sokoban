# compile coffee file that will be loaded by the server in javascript 
# to reuse the level methods in ruby

require 'coffee-rails'

def compile_coffee_to_js
  files = ['level_core', 'path_core', 'deadlock_core']
  files.each do |file|
    if File.exist?("lib/assets/#{file}.js")
      File.delete("lib/assets/#{file}.js")
    end
    compile_file_coffee_to_js("app/assets/jax/models/#{file}.js.coffee", "lib/assets/#{file}.js")
  end
end

def compile_file_coffee_to_js(coffee_file, js_file)
  coffee = CoffeeScript.compile File.read(coffee_file)
  File.open(js_file, 'w') do |f|
    f.puts coffee
  end
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
 
###
#  That was only in use for heroku and now we are on dedicated server
###
#  task :deploy => :environment do
#    if Rails.env.production?
#      puts "Cannot use this task in production"
#    else
#      compile_coffee_to_js()
#      # generate right gemfile for production and deploy to server
#      # `export MY_BUNDLE_ENV='production'`
#      ENV['MY_BUNDLE_ENV'] = "production"
#      `bundle update`
#      `bundle install`
#      `git add .`
#      `git commit -a -m "gemfile.lock for production"`
#      `git push heroku master`
#      `heroku run rake db:migrate`
#      `heroku restart`
#      
#      # generate right gemfile for development and save to github
#      #`export MY_BUNDLE_ENV='development'`
#      ENV['MY_BUNDLE_ENV'] = "development"
#      `bundle update`
#      `bundle install`
#      `git add .`
#      `git commit -a -m "gemfile.lock for development"`
#      `git push origin master`
#    end
#  end
end