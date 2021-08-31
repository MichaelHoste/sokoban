namespace :deploy do
  task :refresh_sitemap do
    if fetch(:stage) == :production
      invoke 'deploy:refresh_sitemap'
    end
  end
end
