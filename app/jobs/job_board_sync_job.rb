class JobBoardSyncJob < ApplicationJob
  queue_as :default

  def perform(integration_id = nil)
    if integration_id
      # Sync specific integration
      integration = JobBoardIntegration.find(integration_id)
      sync_integration(integration)
    else
      # Sync all active integrations
      JobBoardIntegration.active.find_each do |integration|
        next unless integration.auto_sync_enabled?
        next unless should_sync?(integration)

        sync_integration(integration)
      end
    end
  end

  private

  def sync_integration(integration)
    return unless integration.can_sync?

    integration.log_sync(
      "auto_sync_started",
      "info",
      "Automatic sync started for #{integration.provider}"
    )

    begin
      # Sync jobs based on settings
      if integration.post_new_jobs?
        sync_new_jobs(integration)
      end

      if integration.update_existing_jobs?
        sync_updated_jobs(integration)
      end

      if integration.delete_closed_jobs?
        sync_closed_jobs(integration)
      end

      integration.update!(last_sync_at: Time.current)

      integration.log_sync(
        "auto_sync_completed",
        "success",
        "Automatic sync completed successfully for #{integration.provider}"
      )
    rescue StandardError => e
      integration.log_sync(
        "auto_sync_failed",
        "error",
        "Automatic sync failed for #{integration.provider}: #{e.message}",
        metadata: { error_details: e.backtrace.first(5) }
      )
    end
  end

  def sync_new_jobs(integration)
    # Find jobs that haven't been synced yet
    new_jobs = integration.company.jobs.published
                           .where("created_at > ?", integration.last_sync_at || 1.month.ago)
                           .where.not(id: integration.jobs.pluck(:id))

    new_jobs.find_each do |job|
      integration.sync_job(job)
    end
  end

  def sync_updated_jobs(integration)
    # Find jobs that have been updated since last sync
    updated_jobs = integration.company.jobs.published
                              .where("updated_at > ?", integration.last_sync_at || 1.month.ago)

    updated_jobs.find_each do |job|
      integration.sync_job(job)
    end
  end

  def sync_closed_jobs(integration)
    # Find jobs that have been closed since last sync
    closed_jobs = integration.company.jobs.closed
                             .where("updated_at > ?", integration.last_sync_at || 1.month.ago)

    closed_jobs.find_each do |job|
      JobBoardSyncService.new(integration, job).delete_job
    end
  end

  def should_sync?(integration)
    return true if integration.last_sync_at.nil?

    # Check if enough time has passed since last sync
    integration.last_sync_at < integration.sync_interval.seconds.ago
  end
end
