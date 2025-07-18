class CreateSkills < ActiveRecord::Migration[8.0]
  def change
    create_table :skills do |t|
      t.string :name, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
