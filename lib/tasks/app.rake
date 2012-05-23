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
  
  task :compile_coffee => :environment do
    if Rails.env.production?
      puts "Cannot use this task in production"
    else
      compile_coffee_to_js()
    end
  end
end
