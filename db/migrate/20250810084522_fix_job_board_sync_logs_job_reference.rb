class FixJobBoardSyncLogsJobReference < ActiveRecord::Migration[8.0]
  def change
    # Remove the not null constraint and foreign key
    remove_foreign_key :job_board_sync_logs, :jobs, if_exists: true
    change_column_null :job_board_sync_logs, :job_id, true

    # Add back the foreign key with allow_null: true
    add_foreign_key :job_board_sync_logs, :jobs, on_delete: :cascade
  end
end
