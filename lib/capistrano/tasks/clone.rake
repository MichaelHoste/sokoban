# CLONE PRODUCTION TO DEVELOPMENT : "bundle exec cap production deploy:clone_to_development"

namespace :deploy do
  task :clone_to_development do
    if fetch(:stage) == :production
      config_dev = YAML::load(File.read('config/database.yml'))['development']
      config_pro = YAML::load(File.read('config/database.yml'))['production']

      run_locally do
        execute "rm -f tmp/production.sql tmp/production.sql.gz"
      end

      on roles(:db) do
        execute "mysqldump -u #{config_pro['username']} -p#{config_pro['password']} #{config_pro['database']} | gzip -9 > /home/deploy/production.sql.gz"
        download! '/home/deploy/production.sql.gz', 'tmp/production.sql.gz'
      end

      run_locally do
        execute "bundle exec rake db:drop"
        execute "bundle exec rake db:create"
        execute "gunzip tmp/production.sql.gz"
        passwd_option = config_dev['password'].nil? ? '' : "-p#{dev_config['password']}"
        execute "mysql -u #{config_dev['username']} #{passwd_option} #{config_dev['database']} < tmp/production.sql"
        execute "bundle exec rake db:migrate"
      end
    else
      abort "Run this command with production only !"
    end
  end
end
