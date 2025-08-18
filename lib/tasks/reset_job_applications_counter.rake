namespace :jobs do
  desc "Reset job_applications_count counter cache for all jobs"
  task reset_applications_counter: :environment do
    puts "Resetting job_applications_count counter cache..."

    Job.find_each do |job|
      job.update_column(:job_applications_count, job.job_applications.count)
      print "."
    end

    puts "\nDone! Reset counter cache for #{Job.count} jobs."
  end
end
