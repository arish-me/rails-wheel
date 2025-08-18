class AddExpiredStatusToJobs < ActiveRecord::Migration[7.1]
  def up
    # Update existing published jobs that have passed their expiration date to 'expired' status
    execute <<-SQL
      UPDATE jobs#{' '}
      SET status = 'expired'#{' '}
      WHERE status = 'published'#{' '}
      AND expires_at IS NOT NULL#{' '}
      AND expires_at <= NOW()
    SQL
  end

  def down
    # Revert expired jobs back to published status
    execute <<-SQL
      UPDATE jobs#{' '}
      SET status = 'published'#{' '}
      WHERE status = 'expired'
    SQL
  end
end
