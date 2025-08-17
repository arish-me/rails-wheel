class AddJobApplicationsCountToJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :jobs, :job_applications_count, :integer, default: 0, null: false
    add_index :jobs, :job_applications_count
  end
end
