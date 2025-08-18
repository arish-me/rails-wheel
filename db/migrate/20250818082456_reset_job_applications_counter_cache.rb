class ResetJobApplicationsCounterCache < ActiveRecord::Migration[7.1]
  # def up
  #   Job.find_each do |job|
  #     Job.reset_counters(job.id, :job_applications)
  #   end
  # end

  # def down
  #   # No rollback needed for counter cache reset
  # end
end
