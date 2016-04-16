  # CLONE PRODUCTION TO DEVELOPMENT : "cap deploy:clone_to_development"

namespace :deploy do
  task :clone_to_development do
    if fetch(:stage) == :production
      config_dev = YAML::load(File.read('config/database.yml'))['development']
      config_pro = YAML::load(File.read('config/database.yml'))['production']

      on roles(:db) do
        execute "mysqldump -u #{config_pro['username']} -p#{config_pro['password']} #{config_pro['database']} | gzip -9 > /home/deploy/production.sql.gz"
        download! '/home/deploy/production.sql.gz', 'tmp/production.sql.gz'
      end

      run_locally do
        execute "bundle exec rake db:drop"
        execute "bundle exec rake db:create"
        execute "gunzip tmp/sokoban_dump.sql.gz"
        execute "mysql -u #{config_dev['username']} -p#{config_dev['password']} #{config_dev['database']} < tmp/sokoban_dump.sql"
        execute "bundle exec rake db:migrate"
        execute "rm tmp/sokoban_dump.sql"
      end
    else
      abort "Run this command with production only !"
    end
  end
end
