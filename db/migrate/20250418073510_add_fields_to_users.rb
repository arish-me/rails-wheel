class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    # Omniauth
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    # Other Attributes
    add_column :users, :user_type, :integer
    add_column :users, :gender, :integer
    add_column :users, :bio, :text
    add_column :users, :timezone, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :country_code, :string, default: 'US'
    add_column :users, :phone_number, :string
    add_column :users, :date_of_birth, :date
    add_column :users, :date_format, :string, default: "%d.%m.%Y"
    add_column :users, :locale, :string, default: "en"
    add_column :users, :location, :string
    add_column :users, :website, :string
    add_column :users, :social_links, :jsonb, default: {}
    add_column :users, :theme, :integer, default: 0

    add_column :users, :active, :boolean, default: true, null: false
    add_column :users, :onboarded_at, :datetime
    add_column :users, :goals, :text, array: true, default: []
    add_column :users, :set_onboarding_preferences_at, :datetime
    add_column :users, :set_onboarding_goals_at, :datetime


    add_index :users, :theme
    add_index :users, :locale
    add_index :users, :onboarded_at
  end
end
