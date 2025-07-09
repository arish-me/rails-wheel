class UpdateRoleTypeAndRoleLevelAssociations < ActiveRecord::Migration[8.0]
  def change
    # Update role_types table
    remove_reference :role_types, :candidate, index: true, foreign_key: true
    add_reference :role_types, :work_preference, null: false, foreign_key: { to_table: :candidate_work_preferences }, index: { unique: true }

    # Update role_levels table
    remove_reference :role_levels, :candidate, index: true, foreign_key: true
    add_reference :role_levels, :work_preference, null: false, foreign_key: { to_table: :candidate_work_preferences }, index: { unique: true }
  end
end
