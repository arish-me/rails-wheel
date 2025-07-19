class CreateExperiences < ActiveRecord::Migration[8.0]
  def change
    create_table :experiences do |t|
      t.references :candidate, null: false, foreign_key: true
      t.string :company_name
      t.string :job_title
      t.date :start_date
      t.date :end_date
      t.boolean :current_job, default: false
      t.text :description

      t.timestamps
    end
  end
end
