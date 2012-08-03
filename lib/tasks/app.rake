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
  task :setup do
    if Rails.env.production?
      puts "Cannot use this task in production"
    else
      # the ruby version is automatically defined in the .rbenv-version file
      [ 'git submodule update --init --recursive',      # get submodules of this project
        'git submodule foreach git pull origin master', # update submodules of this project
        'rm log/development.log',                       # rm log files
        'touch log/development.log',                    # rm log files
        'rm log/production.log',                        # rm log files
        'touch log/production.log',                     # rm log files
        'bundle install',                               # install gem dependencies
        'bundle exec rails server'                      # launch server
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