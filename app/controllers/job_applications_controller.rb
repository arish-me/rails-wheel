class JobApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job
  before_action :set_application, only: [ :show, :edit, :update, :destroy, :withdraw, :update_status ]

  def index
    # For company users - show all applications for their job
    if current_user.company == @job.company
      @pagy, @applications = pagy(
        @job.job_applications.includes(:candidate, :user, :reviewed_by)
             .order(applied_at: :desc),
        items: 20
      )
    else
      redirect_to root_path, alert: "You don't have permission to view these applications."
    end
  end

  def show
    # Increment view count when company views the application
    if current_user.company == @job.company
      @application.increment_view_count!
    end
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

  def create
    # Check if user already applied
    if @job.has_applicant?(current_user.candidate)
      redirect_to @job, alert: "You have already applied to this job."
      return
    end

    @application = @job.job_applications.build(application_params)
    @application.candidate = current_user.candidate
    @application.user = current_user

    respond_to do |format|
      if @application.save
        format.html { redirect_to @job, notice: "Your application was submitted successfully!" }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect(@job) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("application_form", partial: "form") }
      end
    end
  end

  def edit
    # Only allow editing if it's the user's own application and it's still in early stages
    unless @application.user == current_user && @application.can_be_withdrawn?
      redirect_to @application, alert: "You can't edit this application."
      nil
    end
  end

  def update
    # Only allow updating if it's the user's own application and it's still in early stages
    unless @application.user == current_user && @application.can_be_withdrawn?
      redirect_to @application, alert: "You can't update this application."
      return
    end

    respond_to do |format|
      if @application.update(application_params)
        format.html { redirect_to @application, notice: "Application was successfully updated." }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect(@application) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("application_form", partial: "form") }
      end
    end
  end

  def withdraw
    if @application.user == current_user && @application.can_be_withdrawn?
      @application.withdraw!
      redirect_to @job, notice: "Your application has been withdrawn."
    else
      redirect_to @application, alert: "You can't withdraw this application."
    end
  end

  def update_status
    # Only company users can update application status
    unless current_user.company == @job.company
      redirect_to @application, alert: "You don't have permission to update this application."
      return
    end

    new_status = params[:status]
    if JobApplication::STATUSES.include?(new_status)
      @application.update!(
        status: new_status,
        status_notes: params[:status_notes],
        reviewed_by: current_user
      )
      redirect_to @application, notice: "Application status updated to #{new_status.titleize}."
    else
      redirect_to @application, alert: "Invalid status."
    end
  end

  def destroy
  end

  private

  def set_job
    @job = Job.find(params[:job_id])
  end

  def set_application
    @application = @job.job_applications.find(params[:id])
  end

  def application_params
    params.require(:job_application).permit(
      :cover_letter, :portfolio_url, :additional_notes, :is_quick_apply, :resume
    )
  end
end
