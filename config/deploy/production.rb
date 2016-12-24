server '163.172.63.142', user: 'deploy', roles: %w{web app db}

set :application,  'sokoban'
set :deploy_to,    '/home/deploy/apps/sokoban'
set :branch,       'master'
set :rbenv_ruby,   File.read('.ruby-version').strip
