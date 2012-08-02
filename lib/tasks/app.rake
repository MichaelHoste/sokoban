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
  task :server do
    if Rails.env.production?
      puts "Cannot use this task in production"
    else
      [ 'git submodule update --init --recursive',
        'git submodule foreach git pull origin master',
        'rm log/development.log',
        'touch log/development.log',
        'rm log/production.log',
        'touch log/production.log',
        'bundle install',
        'bundle exec rails server'
      ].each do |command|
        puts command
        system(command)
      end
    end
  end

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
end