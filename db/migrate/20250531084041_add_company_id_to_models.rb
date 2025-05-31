class AddCompanyIdToModels < ActiveRecord::Migration[8.0]
  def change
    add_reference :roles, :company, null: true, foreign_key: true
    add_reference :role_permissions, :company, null: true, foreign_key: true
    add_reference :user_roles, :company, null: true, foreign_key: true
    add_reference :permissions, :company, null: true, foreign_key: true
  end
end
