class CreatePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :permissions do |t|
      t.string :name
      t.string :resource

      t.timestamps
    end
  end
end
