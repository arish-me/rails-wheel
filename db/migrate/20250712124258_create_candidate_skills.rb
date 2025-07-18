class CreateCandidateSkills < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate_skills do |t|
      t.references :candidate, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true

      t.timestamps
    end
    add_index :candidate_skills, [ :candidate_id, :skill_id ], unique: true
  end
end
