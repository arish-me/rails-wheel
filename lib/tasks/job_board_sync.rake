namespace :job_board_sync do
  desc "Sync all active job board integrations"
  task sync_all: :environment do
    puts "Starting job board sync for all active integrations..."

    JobBoardIntegration.active.auto_sync_enabled.find_each do |integration|
      puts "Syncing integration: #{integration.display_name}"
      JobBoardSyncJob.perform_later(integration.id)
    end

    puts "Job board sync jobs queued successfully!"
  end

  desc "Sync a specific integration by ID"
  task :sync_integration, [ :integration_id ] => :environment do |task, args|
    integration_id = args[:integration_id]

    unless integration_id
      puts "Error: Please provide an integration ID"
      puts "Usage: rake job_board_sync:sync_integration[123]"
      exit 1
    end

    integration = JobBoardIntegration.find(integration_id)
    puts "Syncing integration: #{integration.display_name}"

    JobBoardSyncJob.perform_later(integration.id)
    puts "Sync job queued successfully!"
  end

  desc "Test connection for all integrations"
  task test_connections: :environment do
    puts "Testing connections for all integrations..."

    JobBoardIntegration.active.find_each do |integration|
      puts "Testing connection for: #{integration.display_name}"
      result = integration.test_connection
      puts "  Result: #{result[:success] ? 'SUCCESS' : 'FAILED'} - #{result[:message]}"
    end

    puts "Connection tests completed!"
  end

  desc "Show sync statistics"
  task stats: :environment do
    puts "Job Board Integration Statistics"
    puts "=" * 40

    JobBoardIntegration.includes(:job_board_sync_logs).find_each do |integration|
      stats = integration.sync_stats
      puts "\n#{integration.display_name}"
      puts "  Status: #{integration.status}"
      puts "  Total Syncs: #{stats[:total_syncs]}"
      puts "  Successful: #{stats[:successful_syncs]}"
      puts "  Failed: #{stats[:failed_syncs]}"
      puts "  Last Sync: #{stats[:last_sync] ? stats[:last_sync].strftime('%Y-%m-%d %H:%M:%S') : 'Never'}"
      puts "  Auto Sync: #{integration.auto_sync_enabled? ? 'Enabled' : 'Disabled'}"
    end
  end

  desc "Clean old sync logs (older than 30 days)"
  task clean_logs: :environment do
    puts "Cleaning old sync logs..."

    old_logs = JobBoardSyncLog.where("created_at < ?", 30.days.ago)
    count = old_logs.count

    if count > 0
      old_logs.destroy_all
      puts "Deleted #{count} old sync logs"
    else
      puts "No old logs to clean"
    end
  end

  desc "Reset integration status to active"
  task reset_status: :environment do
    puts "Resetting integration statuses..."

    JobBoardIntegration.where(status: :error).update_all(status: :active)
    puts "Reset #{JobBoardIntegration.where(status: :error).count} integrations from error to active"
  end
end
