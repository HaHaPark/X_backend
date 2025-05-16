# config/schedule.rb

# Run task every day at 2 AM.
every 1.day, at: '2:00 am' do
  rake "task_progress:aggregate"
end

#Log results in Rails log folder
set :output, "log/cron.log"

