class CreateCandidates < ActiveRecord::Migration[8.0]
  def change
    create_table :candidates do |t|
      t.references :user, null: false, foreign_key: true
      t.references :candidate_role, foreign_key: true
      t.string :role_levels, array: true, null: false, default: []
      t.string :role_types, array: true, null: false, default: []
      t.string :public_profile_key
      t.integer :search_status
      t.string :headline
      t.integer :experience
      t.decimal :hourly_rate
      t.integer :response_rate, default: 0, null: false
      t.integer :search_score, default: 0, null: false
      t.timestamps
    end
  end
end
