class CreateThemes < ActiveRecord::Migration[8.0]
  def change
    create_table :themes do |t|
      t.string :name
      t.json :settings
      t.references :site, null: false, foreign_key: true

      t.timestamps
    end
  end
end
