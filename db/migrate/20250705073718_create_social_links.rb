class CreateSocialLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :social_links do |t|
      t.references :linkable, polymorphic: true, null: false
      t.string :github
      t.string :linked_in
      t.string :website
      t.string :twitter

      t.timestamps
    end
    add_index :social_links, [ :linkable_type, :linkable_id ]
  end
end
