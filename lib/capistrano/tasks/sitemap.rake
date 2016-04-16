namespace :deploy do
  task :refresh_sitemap do
    if fetch(:stage) == :production
      invoke 'deploy:sitemap:refresh'
    end
  end
end
