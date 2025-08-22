module JobAuthorizable
  extend ActiveSupport::Concern

  private

  def authorize_job_access
    return if @job.blank?

    authorize @job
  end

  def authorize_job_ownership
    return if @job.blank?

    return if current_user.company == @job.company

    redirect_to jobs_path, alert: "You don't have permission to access this job."
  end

  def authorize_job_creation
    return if current_user.company.present?

    redirect_to root_path, alert: "You must be associated with a company to create jobs."
  end

  def can_manage_job?(job)
    return false if job.blank?

    current_user.company == job.company
  end

  def can_publish_job?(job)
    return false if job.blank?

    can_manage_job?(job) && job.can_be_published?
  end

  def can_close_job?(job)
    return false if job.blank?

    can_manage_job?(job) && job.can_be_closed?
  end
end
