namespace :jobs do
  desc "Expire jobs that have passed their expiration date"
  task expire: :environment do
    puts "Starting job expiration process..."
    ExpireJobsJob.perform_now
    puts "Job expiration process completed."
  end

  desc "Schedule job expiration check (for cron)"
  task schedule_expiration_check: :environment do
    puts "Scheduling job expiration check..."
    ExpireJobsJob.perform_later
    puts "Job expiration check scheduled."
  end
end
