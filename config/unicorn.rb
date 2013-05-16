working_directory "/home/deploy/apps/sokoban/current"
#pid               "/home/deploy/apps/sokoban/shared/pids/unicorn.pid"
stderr_path       "/home/deploy/apps/sokoban/shared/log/unicorn.log"
stdout_path       "/home/deploy/apps/sokoban/shared/log/unicorn.log"

# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true

listen "/tmp/unicorn.sokoban.sock" # :backlog => 2048, tries => 10

worker_processes 2
timeout 30

# combine Ruby 2.0.0dev or REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
