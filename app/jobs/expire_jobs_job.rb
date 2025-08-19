class ExpireJobsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting job expiration check..."

    # Use the class method to expire jobs
    expired_count = Job.expire_expired_jobs

    if expired_count > 0
      Rails.logger.info "Successfully expired #{expired_count} jobs"

      # Optionally send notifications for expired jobs
      Job.where(status: "expired").where("updated_at >= ?", 1.minute.ago).each do |job|
        notify_company_about_expired_job(job)
      end
    else
      Rails.logger.info "No expired jobs found"
    end
  end

  private

  def notify_company_about_expired_job(job)
    # Send notification to company users about the expired job
    job.company.users.each do |user|
      # You can implement notification logic here
      # For example, send email, push notification, etc.
      Rails.logger.info "Notifying user #{user.email} about expired job '#{job.title}'"
    end
  rescue => e
    Rails.logger.error "Error notifying about expired job: #{e.message}"
  end
end
