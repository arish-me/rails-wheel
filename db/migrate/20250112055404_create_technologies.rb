class CreateTechnologies < ActiveRecord::Migration[8.0]
  def change
    create_table :technologies do |t|
      t.string :name
      t.string :subtitle
      t.text :description
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
