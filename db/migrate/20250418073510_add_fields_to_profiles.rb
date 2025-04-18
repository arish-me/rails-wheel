class AddFieldsToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :phone_number, :string
    add_column :profiles, :date_of_birth, :date
    add_column :profiles, :location, :string
    add_column :profiles, :website, :string
    add_column :profiles, :social_links, :jsonb, default: {}
    add_column :profiles, :theme_preference, :integer, default: 0

    add_index :profiles, :theme_preference
  end
end
