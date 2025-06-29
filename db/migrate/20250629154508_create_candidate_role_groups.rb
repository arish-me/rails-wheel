class CreateCandidateRoleGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate_role_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
