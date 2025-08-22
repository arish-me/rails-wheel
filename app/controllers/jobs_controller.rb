class JobsController < ApplicationController
  include JobAuthorizable

  before_action :authenticate_user!
  before_action :set_job, only: %i[show edit update destroy publish close]
  before_action :authorize_job_access, only: %i[show edit update destroy publish close]
  before_action :load_skills, only: %i[new edit create update]
  before_action :authorize_job_creation, only: %i[new create]

  # ============================================================================
  # ACTIONS
  # ============================================================================

  def index
    @pagy, @jobs = pagy(
      current_user.company.jobs.recent,
      items: 10
    )
  end

  def show
    @job_service = JobService.new(@job, current_user)
    @job_service.increment_views! unless @job_service.can_manage_job?
    @recent_applications = @job.recent_applications(limit: 5)
  end

  def new
    @job = current_user.company.jobs.build
  end

  def edit
    # Job is already loaded via before_action
  end

  def create
    @job = current_user.company.jobs.build(job_params)
    @job.created_by = current_user

    if @job.save
      redirect_to @job, notice: "Job was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @job.update(job_params)
      redirect_to @job, notice: "Job was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @job.destroy!

    respond_to do |format|
      format.html { redirect_to jobs_path, notice: "Job was successfully deleted." }
      format.turbo_stream { render turbo_stream: turbo_stream.redirect(jobs_path) }
    end
  end

  def publish
    @job_service = JobService.new(@job, current_user)
    result = @job_service.publish_job

    if result.success?
      redirect_to @job, notice: result.message
    else
      redirect_to @job, alert: result.message
    end
  end

  def close
    @job_service = JobService.new(@job, current_user)
    result = @job_service.close_job

    if result.success?
      redirect_to @job, notice: result.message
    else
      redirect_to @job, alert: result.message
    end
  end

  # ============================================================================
  # PRIVATE METHODS
  # ============================================================================

  private

  def set_job
    @job = Job.friendly.find(params[:id])
  end

  def load_skills
    @skills = Skill.order(:name)
    @candidate_role_groups = CandidateRoleGroup.with_candidate_roles.all
  end

  def job_params
    params.expect(
      job: [ :title, :description, :requirements, :benefits,
            :role_type, :role_level, :remote_policy,
            :salary_min, :salary_max, :salary_currency, :salary_period,
            :status, :featured, :expires_at, :worldwide,
            :allow_cover_letter, :require_portfolio, :application_instructions,
            :external_id, :external_source, { external_data: {},
                                              candidate_role_ids: [],
                                              skill_ids: [],
                                              location_attributes: %i[
                                                id location_search city state country _destroy
                                              ] } ]
    )
  end
end
