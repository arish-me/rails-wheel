class CreateSubscriptionPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :subscription_plans do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.string :tier
      t.jsonb :features
      t.boolean :active
      t.integer :trial_days

      t.timestamps
    end
  end
end
