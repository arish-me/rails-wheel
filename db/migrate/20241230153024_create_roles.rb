class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :name
      t.boolean :is_default, default: false, null: false
      t.timestamps
    end
  end
end
