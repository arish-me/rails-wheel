class CreateTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :topics do |t|
      t.string :heading
      t.references :technology, null: false, foreign_key: true

      t.timestamps
    end
  end
end
