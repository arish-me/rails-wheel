class AddCandidateRoleIdsToJobs < ActiveRecord::Migration[8.0]
  def change
    add_reference :jobs, :candidate_role, null: true, foreign_key: true
  end
end
