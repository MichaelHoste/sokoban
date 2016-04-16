# bundle exec cap production deploy:maintenance:enable
# bundle exec cap production deploy:maintenance:disable

namespace :deploy do
  namespace :maintenance do
    task :enable do
      on roles(:app) do
        execute "touch #{shared_path}/public/system/maintenance.txt"
      end

      invoke 'deploy:restart'
    end

    task :disable do
      on roles(:app) do
        execute "rm -f #{shared_path}/public/system/maintenance.txt"
      end

      invoke 'deploy:restart'
    end
  end
end
