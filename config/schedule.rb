# IMPORTANT, check that rbenv/RVM is loaded in ~/.bash_profile (export PATH="$HOME/.rbenv/bin:$PATH";eval "$(rbenv init -)")
set      :output,      "#{path}/log/cron.log"
job_type :bundle_exec, 'cd :path && bundle exec :task :output' # :path is set to project dir by default

every 1.day, :at => '4:30 am' do
  bundle_exec "backup perform --trigger Sokoban -c #{path}/config/backup.rb"
end

every 1.day, :at => '4:40 am' do
  ['cron', 'production', 'unicorn'].each do |log|
    command "echo '' > #{path}/log/#{log}.log"
  end
end

every 1.day, :at => '5:00 am' do
  rake "-s sitemap:refresh"
end
