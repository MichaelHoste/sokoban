require 'bundler/capistrano'
require 'foreman/capistrano'

# Comment when first "cap deploy" (gem is not present yet and "bundle" is made after this)
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
set :use_sudo,    false

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

# Foreman settings
set :foreman_sudo,        "#{sudo} env PATH=$PATH"  # Set to `rvmsudo` if you're using RVM
set :foreman_concurrency, 'web=1,worker=2'

set :keep_releases, 5
after "deploy:restart", "deploy:cleanup"

before "deploy:assets:precompile" do
  # Database
  upload "config/database.yml", "#{deploy_to}/shared/config/database.yml"
  run "ln -s #{deploy_to}/shared/config/database.yml #{latest_release}/config/database.yml;true"

  # Emails
  upload "config/email.yml", "#{deploy_to}/shared/config/email.yml"
  run "ln -s #{deploy_to}/shared/config/email.yml #{latest_release}/config/email.yml;true"
end

namespace :foreman do
  task :export do
    run "cd #{deploy_to}/current && #{foreman_sudo} bundle exec foreman export upstart /etc/init -a #{application} -u #{user} -l #{deploy_to}/shared/log -f Procfile.production -e env.production -c #{foreman_concurrency}"
  end

  task :start do
    "#{sudo} start #{application}"
  end

  task :stop do
    "#{sudo} stop #{application}"
  end

  task :restart do
    run "#{sudo} start #{application} || sudo restart #{application}"
  end
end

namespace :deploy do
  task :start do
    # Thumbs of levels (generated when needed)
    run "unlink #{deploy_to}/current/public/images/levels;true"
    run "ln -s #{deploy_to}/shared/public/images/levels #{deploy_to}/current/public/images/levels;true"

    # Facebook configuration
    run "unlink #{deploy_to}/current/config/initializers/facebook.rb;true"
    run "ln -s #{deploy_to}/shared/config/initializers/facebook.rb #{deploy_to}/current/config/initializers/facebook.rb;true"

    # Madmimi configuration
    run "unlink #{deploy_to}/current/config/initializers/madmimi.rb;true"
    run "ln -s #{deploy_to}/shared/config/initializers/madmimi.rb #{deploy_to}/current/config/initializers/madmimi.rb;true"

    # Errbit configuration
    run "unlink #{deploy_to}/current/config/initializers/errbit.rb;true"
    run "ln -s #{deploy_to}/shared/config/initializers/errbit.rb #{deploy_to}/current/config/initializers/errbit.rb;true"

    # Backup configuration
    run "mkdir #{deploy_to}/current/config/backups;true"
    run "unlink #{deploy_to}/current/config/backups/sokoban.rb;true"
    run "unlink #{deploy_to}/current/config/backup.rb;true"
    run "ln -s #{deploy_to}/shared/config/backups/sokoban.rb #{deploy_to}/current/config/backups/sokoban.rb;true"
    run "ln -s #{deploy_to}/shared/config/backup.rb #{deploy_to}/current/config/backup.rb;true"

    deploy.migrate

    # Export / Restart foreman
    foreman.export
    foreman.restart

    # Launch delayed job for publish feed
    run("cd #{latest_release} && bundle exec rake app:facebook_feed_delayed_job RAILS_ENV=#{rails_env}")

    # Launch delayed job for sending (weekly) mailing list
    run("cd #{latest_release} && bundle exec rake app:send_mailing_delayed_job RAILS_ENV=#{rails_env}")

    # Regeneration of sitemap
    run("cd #{latest_release} && bundle exec rake sitemap:refresh RAILS_ENV=#{rails_env}")
  end

  task :stop do
    foreman.stop
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

  upload "config/initializers/facebook.rb", "#{deploy_to}/shared/config/initializers/facebook.rb"
  upload "config/initializers/madmimi.rb", "#{deploy_to}/shared/config/initializers/madmimi.rb"
  upload "config/initializers/errbit.rb", "#{deploy_to}/shared/config/initializers/errbit.rb"
  upload "config/backups/sokoban.rb", "#{deploy_to}/shared/config/backups/sokoban.rb"
  upload "config/backup.rb", "#{deploy_to}/shared/config/backup.rb"
end

