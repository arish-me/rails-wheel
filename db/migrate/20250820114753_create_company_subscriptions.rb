class CreateCompanySubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :company_subscriptions do |t|
      t.references :company, null: false, foreign_key: true
      t.integer :status
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
