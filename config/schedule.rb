set      :output,         "#{path}/log/cron.log"
job_type :bundle_exec,    'cd :path && bundle exec :task :output' # :path is set to project dir by default
job_type :simple_command, 'cd :path && :task :output'

every 1.day, :at => '4:30 am' do
  simple_command "backup perform --trigger sokoban -c #{path}/config/backup.rb"
end

every 1.day, :at => '5:00 am' do
  rake "-s sitemap:refresh"
end
