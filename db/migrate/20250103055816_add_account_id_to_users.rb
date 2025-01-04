class AddAccountIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :account_id, :integer
    add_index  :users, :account_id
  end
end
