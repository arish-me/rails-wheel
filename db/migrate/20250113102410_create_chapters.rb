class CreateChapters < ActiveRecord::Migration[8.0]
  def change
    create_table :chapters do |t|
      t.string :name
      t.text :content
      t.references :topic, null: false, foreign_key: true
      t.string :slug
      t.string :duration
      t.timestamps
    end
    add_index :chapters, :slug, unique: true
  end
end
