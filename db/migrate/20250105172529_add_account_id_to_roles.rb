class AddAccountIdToRoles < ActiveRecord::Migration[8.0]
  def change
     add_reference :roles, :account, null: false, foreign_key: true, index: true
     add_reference :permissions, :account, null: false, foreign_key: true, index: true
     add_reference :role_permissions, :account, null: false, foreign_key: true, index: true
     add_reference :categories, :account, null: false, foreign_key: true, index: true
     add_reference :user_roles, :account, null: false, foreign_key: true, index: true
  end
end
