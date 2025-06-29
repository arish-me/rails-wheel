class CreateCandidateWorkPreference < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate_work_preferences do |t|
      t.belongs_to :candidate, index: {unique: true}, foreign_key: true
      t.integer :search_status
      t.timestamps
    end
  end
end
