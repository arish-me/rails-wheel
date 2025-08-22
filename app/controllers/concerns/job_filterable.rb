module JobFilterable
  extend ActiveSupport::Concern

  private

  def apply_job_filters(jobs, filters)
    jobs = apply_search_filter(jobs, filters[:search])
    jobs = apply_job_type_filter(jobs, filters[:role_type])
    jobs = apply_experience_filter(jobs, filters[:role_level])
    jobs = apply_remote_policy_filter(jobs, filters[:remote_policy])
    jobs = apply_location_filter(jobs, filters[:location])
    jobs = apply_company_filter(jobs, filters[:company_id])
    jobs = apply_featured_filter(jobs, filters[:featured])
    apply_sorting(jobs, filters[:sort])
  end

  def apply_search_filter(jobs, search_term)
    return jobs if search_term.blank?

    jobs.search_by_title_and_description(search_term)
  end

  def apply_job_type_filter(jobs, job_type)
    return jobs if job_type.blank?

    jobs.by_job_type(job_type)
  end

  def apply_experience_filter(jobs, experience_level)
    return jobs if experience_level.blank?

    jobs.by_experience_level(experience_level)
  end

  def apply_remote_policy_filter(jobs, remote_policy)
    return jobs if remote_policy.blank?

    jobs.by_remote_policy(remote_policy)
  end

  def apply_location_filter(jobs, location)
    return jobs if location.blank?

    jobs.by_location(location)
  end

  def apply_company_filter(jobs, company_id)
    return jobs if company_id.blank?

    jobs.by_company_id(company_id)
  end

  def apply_featured_filter(jobs, featured)
    return jobs unless featured == 'true'

    jobs.featured
  end

  def apply_sorting(jobs, sort_option)
    case sort_option
    when 'newest'
      jobs.newest_first
    when 'oldest'
      jobs.oldest_first
    when 'salary_high'
      jobs.salary_high_to_low
    when 'salary_low'
      jobs.salary_low_to_high
    when 'applications'
      jobs.most_applications
    when 'views'
      jobs.most_views
    else
      jobs.newest_first # Default: newest first
    end
  end

  def load_filter_options
    @companies = Company.joins(:jobs)
                        .where(jobs: { status: 'published' })
                        .distinct
                        .order(:name)

    @locations = Job.published.active
                    .where.not(location: [nil, ''])
                    .distinct
                    .pluck(:location)
                    .compact
                    .sort
  end
end
