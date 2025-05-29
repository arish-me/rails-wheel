class EnsureTimezoneFieldForProfiles < ActiveRecord::Migration[8.0]
  def change
    # Add timezone field if it doesn't exist
    add_column :profiles, :timezone, :string unless column_exists?(:profiles, :timezone)

    # Add country_code field if it doesn't exist
    add_column :profiles, :country_code, :string unless column_exists?(:profiles, :country_code)

    # Add postal_code field if it doesn't exist
    add_column :profiles, :postal_code, :string unless column_exists?(:profiles, :postal_code)

    # Add index to country_code if it doesn't exist
    add_index :profiles, :country_code unless index_exists?(:profiles, :country_code)
  end
end
