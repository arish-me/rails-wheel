class CreateCandidateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate_profiles do |t|
      t.references :candidate, null: false, foreign_key: true
      t.references :candidate_role, foreign_key: true
      t.integer :experience
      t.decimal :hourly_rate

      t.timestamps
    end
  end
end
