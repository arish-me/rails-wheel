class CreateTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :topics do |t|
      t.string :heading
      t.references :course, null: false, foreign_key: true
      t.string :slug
      t.string :duration
      t.timestamps
    end
    add_index :topics, :slug, unique: true
  end
end
