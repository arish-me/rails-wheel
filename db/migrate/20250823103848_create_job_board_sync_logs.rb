class CreateJobBoardSyncLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :job_board_sync_logs do |t|
      t.references :job_board_integration, null: false, foreign_key: true
      t.references :job, null: true, foreign_key: true
      t.string :action, null: false
      t.string :status, null: false
      t.text :message
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :job_board_sync_logs, [ :job_board_integration_id, :created_at ]
    add_index :job_board_sync_logs, :action
    add_index :job_board_sync_logs, :status
    add_index :job_board_sync_logs, :metadata, using: :gin
  end
end
