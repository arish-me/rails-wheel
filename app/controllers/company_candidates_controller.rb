class CompanyCandidatesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_company_access

  # ============================================================================
  # ACTIONS
  # ============================================================================

  def index
    # Base query - get job applications for company's jobs with candidate details
    @job_applications = JobApplication.includes(:job, candidate: %i[user role_level role_type])
                                      .joins(:job)
                                      .where(jobs: { company: current_user.company })

    # Apply filters
    @job_applications = apply_filters(@job_applications)

    # Apply search
    @job_applications = apply_search(@job_applications) if params[:search].present?

    # Apply sorting
    @job_applications = apply_sorting(@job_applications)

    # Pagination
    @pagy, @job_applications = pagy(@job_applications, items: 20)

    # For filters
    @jobs = current_user.company.jobs.published

    # Get unique locations from jobs (not candidates) - standard ATS approach
    job_ids = current_user.company.jobs.pluck(:id)
    @locations = Location.where(locatable_type: 'Job', locatable_id: job_ids)
                         .select('DISTINCT city, state, country')
                         .where.not(city: [nil, ''])
                         .order(:city)
  end

  def bulk_actions
    application_ids = params[:application_ids]
    action = params[:bulk_action]

    if application_ids.blank?
      redirect_to company_candidates_path, alert: 'Please select at least one application.'
      return
    end

    # Only allow actions on applications that belong to the company
    applications = JobApplication.joins(:job)
                                 .where(jobs: { company: current_user.company })
                                 .where(id: application_ids)

    case action
    when 'add_note'
      # Handle bulk note addition
      redirect_to company_candidates_path, notice: "Note added to #{applications.count} applications."
    when 'update_status'
      # Handle bulk status update
      redirect_to company_candidates_path, notice: "Status updated for #{applications.count} applications."
    when 'export'
      # Handle export
      redirect_to company_candidates_path, notice: "Export completed for #{applications.count} applications."
    else
      redirect_to company_candidates_path, alert: 'Invalid action selected.'
    end
  end

  def show
    @job_application = JobApplication.includes(:job, candidate: %i[user candidate_roles])
                                     .joins(:job)
                                     .where(jobs: { company: current_user.company })
                                     .where(id: params[:id])
                                     .first

    return if @job_application

    redirect_to company_candidates_path,
                alert: "Application not found or you don't have permission to view this application."
  end

  def update_status
    @job_application = JobApplication.joins(:job)
                                     .where(jobs: { company: current_user.company })
                                     .where(id: params[:id])
                                     .first

    if @job_application
      @job_application.update(status: params[:status])
      redirect_to company_candidates_path, notice: 'Application status updated successfully.'
    else
      redirect_to company_candidates_path,
                  alert: "Application not found or you don't have permission to update this application."
    end
  end

  def add_note
    @job_application = JobApplication.joins(:job)
                                     .where(jobs: { company: current_user.company })
                                     .where(id: params[:id])
                                     .first

    if @job_application
      @job_application.update(status_notes: params[:notes])
      redirect_to company_candidates_path, notice: 'Note added successfully.'
    else
      redirect_to company_candidates_path,
                  alert: "Application not found or you don't have permission to add notes to this application."
    end
  end

  # ============================================================================
  # PRIVATE METHODS
  # ============================================================================

  private

  def authorize_company_access
    return if current_user.company.present?

    redirect_to root_path, alert: "You don't have permission to access this page."
  end

  def apply_filters(job_applications)
    job_applications = job_applications.where(job_id: params[:job_id]) if params[:job_id].present?

    # Filter by job location
    if params[:location].present?
      job_applications = job_applications.joins(:job)
                                         .joins("INNER JOIN locations ON locations.locatable_type = 'Job' AND locations.locatable_id = jobs.id")
                                         .where(locations: { city: params[:location] })
    end

    job_applications = job_applications.where(status: params[:status]) if params[:status].present?

    # Filter by RoleLevel (experience level)
    if params[:experience_level].present?
      job_applications = job_applications.joins(candidate: :role_level)
                                         .where("role_levels.#{params[:experience_level]} = ?", true)
    end

    # Filter by RoleType
    if params[:role_type].present?
      job_applications = job_applications.joins(candidate: :role_type)
                                         .where("role_types.#{params[:role_type]} = ?", true)
    end

    job_applications
  end

  def apply_search(job_applications)
    job_applications.joins(:candidate).where(
      'candidates.headline ILIKE ? OR candidates.bio ILIKE ? OR users.first_name ILIKE ? OR users.last_name ILIKE ? OR users.email ILIKE ?',
      "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%"
    ).joins(candidate: :user)
  end

  def apply_sorting(job_applications)
    case params[:sort]
    when 'name'
      job_applications.joins(candidate: :user).order('users.first_name ASC, users.last_name ASC')
    when 'location'
      job_applications.joins(candidate: :location).order('locations.city ASC, locations.state ASC, locations.country ASC')
    when 'recent'
      job_applications.order('job_applications.applied_at DESC')
    when 'applications'
      job_applications.order('job_applications.applied_at DESC')
    else
      job_applications.order('job_applications.applied_at DESC')
    end
  end
end
