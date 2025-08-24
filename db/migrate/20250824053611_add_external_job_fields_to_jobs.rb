class AddExternalJobFieldsToJobs < ActiveRecord::Migration[8.0]
  def change
    # Only add external_job_id since external_source already exists
    add_column :jobs, :external_job_id, :string
    add_column :jobs, :redirect_url, :string

    # Add indexes for efficient lookups
    add_index :jobs, :external_job_id
    add_index :jobs, [ :external_source, :external_job_id ], unique: true
  end
end
