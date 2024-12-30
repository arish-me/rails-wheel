class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.integer :gender
      t.text :bio
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
