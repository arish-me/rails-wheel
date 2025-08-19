class CreateCompanySubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :company_subscriptions do |t|
      t.references :company, null: false, foreign_key: true
      t.references :subscription_plan, null: false, foreign_key: true
      t.string :status
      t.datetime :trial_start
      t.datetime :trial_end

      t.timestamps
    end
  end
end
