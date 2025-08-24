class JobBoardSyncService
  attr_reader :integration, :adapter

  def initialize(integration)
    @integration = integration
    @adapter = JobBoardAdapters::AdapterFactory.create(integration)
  end

  def test_connection
    start_time = Time.current

    begin
      result = adapter.test_connection

      if result[:success]
        integration.log_sync(
          "test_connection",
          "success",
          result[:message],
          metadata: {
            response_time: Time.current - start_time,
            provider: integration.provider
          }
        )

        integration.update!(status: :active)
        { success: true, message: result[:message] }
      else
        integration.log_sync(
          "test_connection",
          "error",
          result[:message],
          metadata: {
            response_time: Time.current - start_time,
            error: result[:error],
            provider: integration.provider
          }
        )

        integration.update!(status: :error)
        { success: false, message: result[:message] }
      end
    rescue StandardError => e
      integration.log_sync(
        "test_connection",
        "error",
        "Exception during connection test: #{e.message}",
        metadata: {
          response_time: Time.current - start_time,
          error_details: e.backtrace.first(5),
          provider: integration.provider
        }
      )

      integration.update!(status: :error)
      { success: false, message: "Connection failed: #{e.message}" }
    end
  end

  # Bidirectional sync - pull jobs from external board and sync with local jobs
  def sync_all_jobs
    return { success: false, message: "Integration is not active" } unless integration.can_sync?

    start_time = Time.current

    begin
      # Step 1: Pull jobs from external job board using adapter
      external_jobs_result = adapter.fetch_jobs

      if external_jobs_result[:success]
        external_jobs = external_jobs_result[:data]

        # Step 2: Process each external job
        processed_count = process_external_jobs(external_jobs)

        integration.log_sync(
          "sync_all_jobs",
          "success",
          "Successfully synced #{processed_count} jobs from #{integration.provider}",
          metadata: {
            response_time: Time.current - start_time,
            jobs_processed: processed_count,
            total_external_jobs: external_jobs.length,
            total_count: external_jobs_result[:total_count],
            mean_salary: external_jobs_result[:mean_salary]
          }
        )

        integration.update!(last_sync_at: Time.current)
        { success: true, message: "Synced #{processed_count} jobs successfully" }
      else
        integration.log_sync(
          "sync_all_jobs",
          "error",
          "Failed to fetch jobs from #{integration.provider}: #{external_jobs_result[:message]}",
          metadata: {
            response_time: Time.current - start_time,
            error: external_jobs_result[:message]
          }
        )

        { success: false, message: external_jobs_result[:message] }
      end
    rescue StandardError => e
      integration.log_sync(
        "sync_all_jobs",
        "error",
        "Exception during job sync: #{e.message}",
        metadata: {
          response_time: Time.current - start_time,
          error_details: e.backtrace.first(5)
        }
      )

      { success: false, message: "Sync failed: #{e.message}" }
    end
  end

  # Push a single local job to external board (for when local job is created/updated)
  def push_job_to_external(job)
    return { success: false, message: "Integration is not active" } unless integration.can_sync?
    return { success: false, message: "Job is required" } unless job

    start_time = Time.current

    begin
      # Transform job data using adapter
      job_data = adapter.transform_local_job(job)

      # Push job using adapter
      result = adapter.push_job(job_data)

      if result[:success]
        integration.log_sync(
          "push_job",
          "success",
          "Successfully pushed job '#{job.title}' to #{integration.provider}",
          job: job,
          metadata: {
            response_time: Time.current - start_time,
            job_data: job_data
          }
        )

        integration.update!(last_sync_at: Time.current)
        { success: true, message: "Job pushed successfully" }
      else
        integration.log_sync(
          "push_job",
          "error",
          "Failed to push job '#{job.title}' to #{integration.provider}: #{result[:message]}",
          job: job,
          metadata: {
            response_time: Time.current - start_time,
            job_data: job_data,
            error: result[:message]
          }
        )

        { success: false, message: result[:message] }
      end
    rescue StandardError => e
      integration.log_sync(
        "push_job",
        "error",
        "Exception during job push: #{e.message}",
        job: job,
        metadata: {
          response_time: Time.current - start_time,
          error_details: e.backtrace.first(5)
        }
      )

      { success: false, message: "Push failed: #{e.message}" }
    end
  end

  def delete_job_from_external(job)
    return { success: false, message: "Integration is not active" } unless integration.can_sync?
    return { success: false, message: "Job is required" } unless job

    start_time = Time.current

    begin
      result = adapter.delete_job(job.external_job_id)

      if result[:success]
        integration.log_sync(
          "delete_job",
          "success",
          "Successfully deleted job '#{job.title}' from #{integration.provider}",
          job: job,
          metadata: {
            response_time: Time.current - start_time
          }
        )

        { success: true, message: "Job deleted successfully" }
      else
        integration.log_sync(
          "delete_job",
          "error",
          "Failed to delete job '#{job.title}' from #{integration.provider}: #{result[:message]}",
          job: job,
          metadata: {
            response_time: Time.current - start_time,
            error: result[:message]
          }
        )

        { success: false, message: result[:message] }
      end
    rescue StandardError => e
      integration.log_sync(
        "delete_job",
        "error",
        "Exception during job deletion: #{e.message}",
        job: job,
        metadata: {
          response_time: Time.current - start_time,
          error_details: e.backtrace.first(5)
        }
      )

      { success: false, message: "Deletion failed: #{e.message}" }
    end
  end

  private

  # Process external jobs and sync with local jobs
  def process_external_jobs(external_jobs)
    processed_count = 0

    external_jobs.each do |external_job_data|
      begin
        # Transform external job data to local format using adapter
        local_job_data = adapter.transform_external_job(external_job_data)
        # Find existing job by external ID or create new one
        job = find_or_initialize_job(local_job_data)
        # Check if job has changed
        if job_changed?(job, local_job_data)
          # Update job with external data
          job.assign_attributes(local_job_data)
          job.save!
          processed_count += 1

          integration.log_sync(
            "job_updated",
            "success",
            "Updated job '#{job.title}' from #{integration.provider}",
            job: job,
            metadata: { external_job_id: external_job_data["id"] }
          )
        else
          # Job hasn't changed, skip
          integration.log_sync(
            "job_unchanged",
            "info",
            "Job '#{job.title}' unchanged, skipping",
            job: job,
            metadata: { external_job_id: external_job_data["id"] }
          )
        end
      rescue StandardError => e
        integration.log_sync(
          "job_processing_error",
          "error",
          "Error processing external job: #{e.message}",
          metadata: {
            external_job_data: external_job_data,
            error: e.message
          }
        )
      end
    end

    processed_count
  end

  # Find existing job by external ID or initialize new one
  def find_or_initialize_job(local_job_data)
    external_job_id = local_job_data[:external_job_id]

    # Try to find by external job ID first
    job = integration.company.jobs.find_by(external_job_id: external_job_id)

    # If not found, try to find by external_id (legacy field)
    if job.nil?
      job = integration.company.jobs.find_by(external_id: external_job_id)
    end

    # If not found, try to find by title and company (fuzzy match)
    if job.nil?
      job = integration.company.jobs.find_by(
        title: local_job_data[:title],
        company: integration.company
      )
    end

    # If still not found, create new job
    if job.nil?
      job = integration.company.jobs.new
    end

    job
  end

  # Check if job has changed compared to external data
  def job_changed?(job, local_job_data)
    return true if job.new_record? # New job

    # Compare key fields
    key_fields = [ :title, :description, :location, :salary_min, :salary_max, :status ]

    key_fields.any? do |field|
      job.send(field) != local_job_data[field]
    end
  end
end
