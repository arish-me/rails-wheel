class CreateJobBoardIntegrations < ActiveRecord::Migration[8.0]
  def change
    create_table :job_board_integrations do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name, null: false
      t.string :provider, null: false
      t.string :api_key, null: false
      t.string :api_secret
      t.string :webhook_url
      t.integer :status, null: false, default: 0
      t.jsonb :settings, default: {}
      t.datetime :last_sync_at

      t.timestamps
    end

    add_index :job_board_integrations, [ :company_id, :provider ], unique: true
    add_index :job_board_integrations, :status
    add_index :job_board_integrations, :settings, using: :gin
    add_index :job_board_integrations, :last_sync_at
  end
end
