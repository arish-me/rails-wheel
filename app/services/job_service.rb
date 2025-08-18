require "ostruct"

class JobService
  attr_reader :job, :user

  def initialize(job, user = nil)
    @job = job
    @user = user
  end

  # ============================================================================
  # JOB PUBLISHING
  # ============================================================================

  def publish_job
    return failure_result("Job cannot be published") unless can_publish_job?

    if job.update(status: "published", published_at: Time.current)
      success_result("Job was successfully published")
    else
      failure_result("Failed to publish job", job.errors.full_messages)
    end
  end

  def close_job
    return failure_result("Job cannot be closed") unless can_close_job?

    if job.update(status: "closed")
      success_result("Job was successfully closed")
    else
      failure_result("Failed to close job", job.errors.full_messages)
    end
  end

  # ============================================================================
  # JOB VALIDATION
  # ============================================================================

  def can_publish_job?
    return false unless user.present?
    return false unless user.company == job.company
    return false unless (job.draft? || job.closed?)
    return false unless job.can_be_published?
    true
  end

  def can_close_job?
    return false unless user.present?
    return false unless user.company == job.company
    return false unless job.can_be_closed?
    true
  end

  def can_manage_job?
    return false unless user.present?
    user.company == job.company
  end

  # ============================================================================
  # JOB STATISTICS
  # ============================================================================

  def increment_views!
    job.increment_views!
  end

  def increment_applications!
    job.increment_applications!
  end

  def get_job_statistics
    {
      applications_count: job.applications_count,
      views_count: job.views_count,
      posted_at: job.created_at,
      published_at: job.published_at,
      expires_at: job.expires_at,
      status: job.status
    }
  end

  # ============================================================================
  # RELATED JOBS
  # ============================================================================

  def find_related_jobs(limit: 3)
    job.related_jobs(limit: limit)
  end

  # ============================================================================
  # JOB SEARCH AND FILTERING
  # ============================================================================

  def self.search_jobs(filters = {})
    jobs = Job.published.active.with_company
    apply_filters(jobs, filters)
  end

  def self.apply_filters(jobs, filters)
    jobs = apply_search_filter(jobs, filters[:search])
    jobs = apply_job_type_filter(jobs, filters[:role_type])
    jobs = apply_experience_filter(jobs, filters[:role_level])
    jobs = apply_remote_policy_filter(jobs, filters[:remote_policy])
    jobs = apply_location_filter(jobs, filters[:location])
    jobs = apply_company_filter(jobs, filters[:company_id])
    jobs = apply_featured_filter(jobs, filters[:featured])
    apply_sorting(jobs, filters[:sort])
  end

  # ============================================================================
  # PRIVATE METHODS
  # ============================================================================

  private

  def success_result(message, data = nil)
    OpenStruct.new(
      success?: true,
      message: message,
      data: data
    )
  end

  def failure_result(message, errors = nil)
    OpenStruct.new(
      success?: false,
      message: message,
      errors: errors
    )
  end

  def self.apply_search_filter(jobs, search_term)
    return jobs unless search_term.present?
    jobs.search_by_title_and_description(search_term)
  end

  def self.apply_job_type_filter(jobs, job_type)
    return jobs unless job_type.present?
    jobs.by_job_type(job_type)
  end

  def self.apply_experience_filter(jobs, experience_level)
    return jobs unless experience_level.present?
    jobs.by_experience_level(experience_level)
  end

  def self.apply_remote_policy_filter(jobs, remote_policy)
    return jobs unless remote_policy.present?
    jobs.by_remote_policy(remote_policy)
  end

  def self.apply_location_filter(jobs, location)
    return jobs unless location.present?
    jobs.by_location(location)
  end

  def self.apply_company_filter(jobs, company_id)
    return jobs unless company_id.present?
    jobs.by_company_id(company_id)
  end

  def self.apply_featured_filter(jobs, featured)
    return jobs unless featured == "true"
    jobs.featured
  end

  def self.apply_sorting(jobs, sort_option)
    case sort_option
    when "newest"
      jobs.newest_first
    when "oldest"
      jobs.oldest_first
    when "salary_high"
      jobs.salary_high_to_low
    when "salary_low"
      jobs.salary_low_to_high
    when "applications"
      jobs.most_applications
    when "views"
      jobs.most_views
    else
      jobs.newest_first
    end
  end
end
