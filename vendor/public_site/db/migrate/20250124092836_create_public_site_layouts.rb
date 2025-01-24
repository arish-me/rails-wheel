class CreatePublicSiteLayouts < ActiveRecord::Migration[8.0]
  def change
    create_table :public_site_layouts do |t|
      t.string :name
      t.text :content
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
