class CreateCandidateWorkPreference < ActiveRecord::Migration[8.0]
  def change
     create_table :candidate_work_preferences do |t|
      t.references :candidate, null: false, foreign_key: true
      t.integer :search_status
      t.integer :role_type
      t.integer :role_level

      t.timestamps
    end
  end
end
