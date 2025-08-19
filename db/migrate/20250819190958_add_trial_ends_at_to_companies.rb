class AddTrialEndsAtToCompanies < ActiveRecord::Migration[8.0]
  def change
    add_column :companies, :trial_ends_at, :datetime
  end
end
