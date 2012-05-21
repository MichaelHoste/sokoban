# compile coffee file that will be loaded by the server in javascript 
# to reuse the level methods in ruby
def create_level_core_js
  `rm -f lib/assets/level_core.js lib/assets/level_core.js.js`
  `coffee --compile --output lib/assets/ app/assets/jax/models/level_core.js.coffee`
  `mv lib/assets/level_core.js.js lib/assets/level_core.js`
end

namespace :app  do
  task :reset => :environment do
    if Rails.env.production?
      puts "Cannot use this task in production"
    else
      create_level_core_js()
      Rake::Task['db:migrate:reset'].invoke
      Rake::Task['db:seed'].invoke
    end
  end
end
