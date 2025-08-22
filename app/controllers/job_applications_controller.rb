class JobApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job
  before_action :set_application,
                only: %i[show edit update destroy withdraw update_status success re_apply]
  before_action :authorize_application_access, only: %i[show edit update withdraw re_apply]
  before_action :authorize_company_access, only: %i[index update_status]

  # ============================================================================
  # ACTIONS
  # ============================================================================

  def index
    @pagy, @applications = pagy(
      @job.job_applications.includes(:user, :candidate).recent,
      items: 20
    )
  end

  def show
    # Increment view count when company views the application
    return unless current_user.company == @job.company

    @application.increment_view_count!
  end

  def new
    # Check if user already applied
    if @job.has_applicant?(current_user.candidate)
      redirect_to @job, alert: "You have already applied to this job."
      return
    end

    # Check if job can be applied to
    unless @job.can_be_applied_to?
      redirect_to @job, alert: "This job is no longer accepting applications."
      return
    end

    @application = @job.job_applications.build(
      candidate: current_user.candidate,
      user: current_user
    )
  end

  def edit
    # Only allow editing if it's the user's own application and it's still in early stages
    return if @application.user == current_user && @application.can_be_withdrawn?

    redirect_to @application, alert: "You can't edit this application."
    nil
  end

  def create
    @application = @job.job_applications.build
    @service = JobApplicationService.new(@application, current_user)
    result = @service.create_application(application_params)
    respond_to do |format|
      if result.success
        format.html { redirect_to success_job_job_application_path(@job, @application), notice: result.message }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    @service = JobApplicationService.new(@application, current_user)
    result = @service.update_application(application_params)

    respond_to do |format|
      if result.success
        format.html { redirect_to [ @job, @application ], notice: result.message }
        # format.turbo_stream { render turbo_stream: turbo_stream.redirect([@job, @application]) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("application_form", partial: "form") }
      end
    end
  end

  def withdraw
    @service = JobApplicationService.new(@application, current_user)
    result = @service.withdraw_application
    redirect_to public_job_path(@job), notice: result.message
  end

  def re_apply
    @service = JobApplicationService.new(@application, current_user)
    result = @service.re_apply
    redirect_to public_job_path(@job), notice: result.message
  end

  def update_status
    @service = JobApplicationService.new(@application, current_user)
    result = @service.update_status(params[:status], params[:status_notes], current_user)
    redirect_to job_job_application_path(@job, @application), notice: result.message
  end

  def destroy; end

  def success
    # This action will be handled by the view
  end

  # ============================================================================
  # PRIVATE METHODS
  # ============================================================================

  private

  def set_job
    @job = Job.friendly.find(params[:job_id])
  end

  def set_application
    @application = @job.job_applications.includes(:user, :candidate).find(params[:id])
  end

  def authorize_application_access
    return if @application.user == current_user || current_user.company == @job.company

    redirect_to root_path, alert: "You don't have permission to access this application."
  end

  def authorize_company_access
    return if current_user.company == @job.company

    redirect_to root_path, alert: "You don't have permission to view these applications."
  end

  def application_params
    params.expect(
      job_application: %i[cover_letter portfolio_url additional_notes is_quick_apply resume]
    )
  end
end
