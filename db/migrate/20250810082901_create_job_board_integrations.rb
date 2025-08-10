class CreateJobBoardIntegrations < ActiveRecord::Migration[8.0]
  def change
    create_table :job_board_integrations do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name
      t.string :provider
      t.string :api_key
      t.string :api_secret
      t.string :webhook_url
      t.jsonb :settings
      t.string :status
      t.datetime :last_sync_at

      t.timestamps
    end
  end
end
