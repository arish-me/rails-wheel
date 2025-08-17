module JobAuthorizable
  extend ActiveSupport::Concern

  included do
    before_action :authorize_job_access, only: [:show, :edit, :update, :destroy, :publish, :close]
  end

  private

  def authorize_job_access
    # authorize @job
  end

  def authorize_job_ownership
    unless current_user.company == @job.company
      redirect_to jobs_path, alert: "You don't have permission to access this job."
    end
  end

  def authorize_job_creation
    unless current_user.company.present?
      redirect_to root_path, alert: "You must be associated with a company to create jobs."
    end
  end

  def can_manage_job?(job)
    current_user.company == job.company
  end

  def can_publish_job?(job)
    can_manage_job?(job) && job.can_be_published?
  end

  def can_close_job?(job)
    can_manage_job?(job) && job.can_be_closed?
  end
end
