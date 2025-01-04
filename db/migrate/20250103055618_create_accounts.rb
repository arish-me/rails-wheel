class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :subdomain
      t.string :contact_email

      t.timestamps
    end
  end
end
