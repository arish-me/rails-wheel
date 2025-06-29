class CreateRoleTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :role_types do |t|
      t.belongs_to :candidate, index: {unique: true}, foreign_key: true

      t.boolean :part_time_contract
      t.boolean :full_time_contract
      t.boolean :full_time_employment

      t.timestamps
    end
  end
end
