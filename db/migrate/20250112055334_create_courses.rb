class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :name
      t.string :subtitle
      t.text :description
      t.string :slug
      t.string :custom_slug
      t.string :duration

      t.timestamps
    end

    # Add a unique index for the slug column
    add_index :courses, :slug, unique: true
  end
end
