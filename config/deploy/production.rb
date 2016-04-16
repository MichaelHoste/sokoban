server '62.210.237.63', user: 'deploy', roles: %w{web app db}

set :application,  'sokoban'
set :deploy_to,    '/home/deploy/apps/sokoban'
set :branch,       'master'
set :rbenv_ruby,   File.read('.ruby-version').strip
