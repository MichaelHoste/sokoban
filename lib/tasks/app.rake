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
      [ 'git submodule update --init --recursive',           # get submodules of this project
        'git submodule foreach git pull origin master',      # update submodules of this project
        'rm log/development.log',                            # rm log files
        'touch log/development.log',                         # rm log files
        'rm log/production.log',                             # rm log files
        'touch log/production.log',                          # rm log files
        'rm log/delayed_job.log',                            # rm log files
        'touch log/delayed_job.log',                         # rm log files
        'rm log/test.log',                                   # rm log files
        'touch log/test.log',                                # rm log files
        'rm chromedriver.log',                               # rm log files
        'bundle install',                                    # install gem dependencies
        "/bin/bash #{Dir.pwd}/script/rename_tab.sh Server"   #
      ].each do |command|
        puts command
        system(command)
      end

      compile_coffee_to_js()

      # Delayed_jobs
      new_tab('Delayed_Jobs', ["cd #{Dir.pwd}",
                               "bundle exec rake jobs:work"])

      # Empty shell
      new_tab('Shell', ["cd #{Dir.pwd}", "clear"])

      # Launch server
      system('bundle exec rails s')
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

def new_tab(name, commands)
  commands = ["/bin/bash #{Dir.pwd}/script/rename_tab.sh #{name}"] + commands
  command_line = commands.collect! { |command| '-e \'tell application "Terminal" to do script "' + command + '" in front window\''}.join(' ')
  `osascript -e 'tell application "Terminal" to activate' \
             -e 'tell application "System Events" to tell process "Terminal" to keystroke "t" using command down' \
             #{command_line} > /dev/null`
end
