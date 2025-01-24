class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :subdomain

      t.timestamps
    end
    add_index :clients, :subdomain, unique: true
  end
end
