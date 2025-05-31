class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :subdomain
      t.string :website
      t.integer :status, default: 0

      t.timestamps
    end
    add_reference :users, :company, null: true, foreign_key: true
  end
end
