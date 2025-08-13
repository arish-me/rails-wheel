class CreateJobApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :job_applications do |t|
      t.references :job, null: false, foreign_key: true
      t.references :candidate, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true # The user who applied

      # Application Status
      t.string :status, default: 'applied' # applied, reviewing, shortlisted, interviewed, offered, rejected, withdrawn
      t.text :status_notes

      # Application Content
      t.text :cover_letter
      t.text :portfolio_url
      t.text :additional_notes

      # Application Settings
      t.boolean :is_quick_apply, default: false # Applied without cover letter
      t.datetime :applied_at
      t.datetime :reviewed_at
      t.references :reviewed_by, foreign_key: { to_table: :users }

      # External Integration
      t.string :external_id # For external job board integration
      t.string :external_source # linkedin, indeed, etc.
      t.jsonb :external_data # Store external application data

      # Analytics
      t.integer :view_count, default: 0 # How many times the application was viewed
      t.datetime :last_viewed_at

      t.timestamps
    end

    add_index :job_applications, :status
    add_index :job_applications, :applied_at
    add_index :job_applications, :reviewed_at
    add_index :job_applications, :external_id
    add_index :job_applications, :external_source
    add_index :job_applications, :external_data, using: :gin
    add_index :job_applications, [ :job_id, :status ]
    add_index :job_applications, [ :candidate_id, :status ]
    add_index :job_applications, [ :user_id, :status ]

    # Ensure one application per candidate per job
    execute "CREATE UNIQUE INDEX index_job_applications_on_job_and_candidate ON job_applications (job_id, candidate_id)"
  end
end
