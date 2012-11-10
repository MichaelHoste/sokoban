require "bundler/capistrano"

set :whenever_command, 'bundle exec whenever'
require 'whenever/capistrano'

# We want Bundler to handle our gems and we want it to package everything locally with the app. 
# The --binstubs flag means any gem executables will be added to <app>/bin 
# and the --shebang ruby-local-exec option makes sure we'll use the ruby version defined in the .rbenv-version in the app root.
set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"

# to find bundle with rbenv
set :default_environment, {
  'PATH' => "/home/deploy/.rbenv/shims:/home/deploy/.rbenv/bin:$PATH"
}

set :application, "sokoban"
set :repository,  "git://github.com/MichaelHoste/#{application}.git"
set :user,        "deploy"
set :deploy_to,   "/home/#{user}/apps/#{application}"
set :use_sudo, false

set :scm,  :git
ssh_options[:forward_agent] = true # use the same ssh keys as my computer for git checkout
set :branch, "master"

default_run_options[:pty] = true

# get the submodules
# set :git_enable_submodules, 1 

set :deploy_via, :remote_cache

role :web, "188.165.255.96"                          # Your HTTP server, Apache/etc
role :app, "188.165.255.96"                          # This may be the same as your `Web` server
role :db,  "188.165.255.96", :primary => true        # This is where Rails migrations will run
# role :db,  "your slave db-server here"

set :keep_releases, 1
after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  task :start do
    # Database
    run "unlink #{deploy_to}/current/config/database.yml;true"
    run "ln -s #{deploy_to}/shared/config/database.yml #{deploy_to}/current/config/database.yml;true"

    # Thumbs of levels (generated when needed)
    run "unlink #{deploy_to}/current/public/images/levels;true"
    run "ln -s #{deploy_to}/shared/public/images/levels #{deploy_to}/current/public/images/levels;true"

    # Facebook configuration
    run "unlink #{deploy_to}/current/config/initializers/facebook.rb;true"
    run "ln -s #{deploy_to}/shared/config/initializers/facebook.rb #{deploy_to}/current/config/initializers/facebook.rb;true"

    # Errbit configuration
    run "unlink #{deploy_to}/current/config/initializers/errbit.rb;true"
    run "ln -s #{deploy_to}/shared/config/initializers/errbit.rb #{deploy_to}/current/config/initializers/errbit.rb;true"
    
    # Backup configuration
    run "mkdir #{deploy_to}/current/config/backups;true"
    run "unlink #{deploy_to}/current/config/backups/socitrad.rb;true"
    run "unlink #{deploy_to}/current/config/backup.rb;true"
    run "ln -s #{deploy_to}/shared/config/backups/socitrad.rb #{deploy_to}/current/config/backups/socitrad.rb;true"
    run "ln -s #{deploy_to}/shared/config/backup.rb #{deploy_to}/current/config/backup.rb;true"
    
    # Unicorn configuration
    unicorn_config_path = "#{deploy_to}/current/config/unicorn.rb"
    run "cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_config_path} -E production -D"
  end

  task :stop do
    unicorn_pid = "#{deploy_to}/shared/pids/unicorn.pid"
    if 'true' ==  capture("if [ -e #{unicorn_pid} ]; then echo 'true'; fi").strip
      run "kill -s QUIT `cat #{unicorn_pid}`;true"
    end
  end

  task :kill do
    unicorn_pid = "#{deploy_to}/shared/pids/unicorn.pid"
    run "kill `cat #{unicorn_pid}`;true"
  end

  task :restart do
    deploy.stop
    deploy.start
  end
end

after 'deploy:setup' do
  run "mkdir #{deploy_to}/shared/config"
  run "mkdir #{deploy_to}/shared/config/initializers"
  run "mkdir #{deploy_to}/shared/public"
  run "mkdir #{deploy_to}/shared/public/images"
  run "mkdir #{deploy_to}/shared/public/images/levels"
  run "mkdir #{deploy_to}/shared/config/backups"
end

after 'deploy:update_code' do
  run "#{sudo} unlink /etc/nginx/sites-enabled/#{application};true"
  run "#{sudo} ln -s #{deploy_to}/current/config/nginx.conf /etc/nginx/sites-enabled/#{application};true"

  upload "config/database.yml", "#{deploy_to}/shared/config/database.yml"
  upload "config/initializers/facebook.rb", "#{deploy_to}/shared/config/initializers/facebook.rb"
  upload "config/initializers/errbit.rb", "#{deploy_to}/shared/config/initializers/errbit.rb"
  upload "config/backups/socitrad.rb", "#{deploy_to}/shared/config/backups/socitrad.rb"
  upload "config/backup.rb", "#{deploy_to}/shared/config/backup.rb"
end
