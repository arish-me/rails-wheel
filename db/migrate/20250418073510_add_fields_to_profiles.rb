class AddFieldsToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :phone_number, :string
    add_column :profiles, :date_of_birth, :date
    add_column :profiles, :date_format, :string, default: "%d-%m%-Y"
    add_column :profiles, :locale, :string, default: "en"
    add_column :profiles, :location, :string
    add_column :profiles, :website, :string
    add_column :profiles, :social_links, :jsonb, default: {}
    add_column :profiles, :theme, :integer, default: 0

    add_column :users, :active, :boolean, default: true, null: false
    add_column :users, :onboarded_at, :datetime
    add_column :users, :goals, :text, array: true, default: []
    add_column :users, :set_onboarding_preferences_at, :datetime
    add_column :users, :set_onboarding_goals_at, :datetime


    add_index :profiles, :theme
  end
end
