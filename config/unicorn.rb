working_directory "/home/deploy/apps/sokoban/current"
pid "/home/deploy/apps/sokoban/shared/pids/unicorn.pid"
stderr_path "/home/deploy/apps/sokoban/shared/log/unicorn.log"
stdout_path "/home/deploy/apps/sokoban/shared/log/unicorn.log"

# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true

listen "/tmp/unicorn.sokoban.sock" #  :backlog => 2048, tries => 10
worker_processes 4
timeout 30