class CreateJobBoardSyncLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :job_board_sync_logs do |t|
      t.references :job_board_integration, null: false, foreign_key: true
      t.references :job, null: false, foreign_key: true
      t.string :action
      t.string :status
      t.text :message
      t.jsonb :metadata

      t.timestamps
    end
  end
end
