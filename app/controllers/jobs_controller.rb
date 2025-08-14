class JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, only: [ :show, :edit, :update, :destroy ]
  before_action :load_skills
  # before_action :authorize_job, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @jobs = pagy(
      current_user.company.jobs.order(created_at: :desc),
      items: 10
    )
  end

  def show
    @job.increment_views! unless current_user.company == @job.company
    @recent_applications = @job.job_applications.includes(:candidate, :user).recent.limit(5)
  end

  def new
    @job = current_user.company.jobs.build
  end

  def create
    @job = current_user.company.jobs.build(job_params)
    @job.created_by = current_user
    # authorize @job

    respond_to do |format|
      if @job.save
        format.html { redirect_to @job, notice: "Job was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to @job, notice: "Job was successfully updated." }
        # format.turbo_stream { render turbo_stream: turbo_stream.redirect(@job) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        # format.turbo_stream { render turbo_stream: turbo_stream.replace('job_form', partial: 'form') }
      end
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
    @job = current_user.company.jobs.friendly.find(params[:id])
    authorize @job
    respond_to do |format|
      if @job.update(status: "published", published_at: Time.current)
        format.html {  redirect_to @job, notice: "Job was successfully published." }
      else
        # format.html { redirect_to @job, alert: "Failed to publish job." }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def close
    @job = current_user.company.jobs.friendly.find(params[:id])
    authorize @job

    if @job.update(status: "closed")
      redirect_to @job, notice: "Job was successfully closed."
    else
      redirect_to @job, alert: "Failed to close job."
    end
  end

  private

  def set_job
    @job = Job.friendly.find(params[:id])
  end

  def authorize_job
    authorize @job
  end

  def load_skills
    @skills = Skill.order(:name)
    @candidate_role_groups = CandidateRoleGroup.includes(:candidate_roles).all
  end

  def set_tenant
    ActsAsTenant.current_tenant = current_user.company
  end

  def job_params
    params.require(:job).permit(
      :title, :description, :requirements, :benefits,
      :role_type, :role_level, :remote_policy,
      :salary_min, :salary_max, :salary_currency, :salary_period,
      :status, :featured, :expires_at,
      :allow_cover_letter, :require_portfolio, :application_instructions,
      :external_id, :external_source, external_data: {},
      candidate_role_ids: [],
      skill_ids: [],
      location_attributes: [
        :id, :location_search, :city, :state, :country, :_destroy
      ]
    )
  end
end
