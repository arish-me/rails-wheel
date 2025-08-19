class AddExpiryDateToCompanySubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :company_subscriptions, :expires_at, :datetime
    add_column :company_subscriptions, :admin_notes, :text
    add_column :company_subscriptions, :updated_by_admin, :integer
  end
end
