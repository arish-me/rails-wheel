class CreateCandidateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate_roles do |t|
      t.string :name
      t.references :candidate_role_group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
