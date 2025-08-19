# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Set the environment
set :environment, Rails.env

# Set the output log file
set :output, "log/cron.log"

# Run job expiration check daily at 2 AM
every 1.day, at: "2:00 am" do
  rake "jobs:expire"
end

# Alternative: Run every hour for more frequent checks
# every 1.hour do
#   rake "jobs:expire"
# end
