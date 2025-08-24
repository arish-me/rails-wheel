class JobBoardIntegrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_job_board_integration, only: [ :show, :edit, :update, :destroy, :test_connection, :sync_job ]
  before_action :ensure_company_access

  def index
    @job_board_integrations = @company.job_board_integrations.includes(:job_board_sync_logs).order(:name)
    @available_providers = JobBoardProvider.active.where.not(slug: @job_board_integrations.pluck(:provider))
  end

  def show
    @sync_logs = @job_board_integration.job_board_sync_logs.recent.limit(20)
    @field_mappings = @job_board_integration.job_board_field_mappings.ordered
    @sync_stats = @job_board_integration.sync_stats
  end

  def new
    @job_board_integration = @company.job_board_integrations.build
    @available_providers = JobBoardProvider.active
  end

  def create
    @job_board_integration = @company.job_board_integrations.build(job_board_integration_params)

    if @job_board_integration.save
      redirect_to job_board_integration_path(@job_board_integration), notice: "Job board integration was successfully created."
    else
      @available_providers = JobBoardProvider.active
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @available_providers = JobBoardProvider.active
  end

  def update
    if @job_board_integration.update(job_board_integration_params)
      redirect_to job_board_integration_path(@job_board_integration), notice: "Job board integration was successfully updated."
    else
      @available_providers = JobBoardProvider.active
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @job_board_integration.destroy
    redirect_to job_board_integrations_path, notice: "Job board integration was successfully deleted."
  end

  def test_connection
    result = @job_board_integration.test_connection

    respond_to do |format|
      format.html { redirect_to job_board_integration_path(@job_board_integration), notice: result[:message] }
      format.json { render json: result }
    end
  end

  def sync_job
    job = Job.find(params[:job_id]) if params[:job_id]
    result = if job
               # Push single job to external board
               JobBoardSyncService.new(@job_board_integration).push_job_to_external(job)
    else
               # Bidirectional sync - pull jobs from external board
               JobBoardSyncService.new(@job_board_integration).sync_all_jobs
    end

    respond_to do |format|
      format.html { redirect_to job_board_integration_path(@job_board_integration), notice: result[:message] }
      format.json { render json: result }
    end
  end

  private

  def set_company
    @company = current_user.company
    redirect_to root_path, alert: "Company not found." unless @company
  end

  def set_job_board_integration
    @job_board_integration = @company.job_board_integrations.find(params[:id])
  end

  def job_board_integration_params
    params.require(:job_board_integration).permit(
      :name, :provider, :api_key, :api_secret, :webhook_url, :status,
      settings: {
        auto_sync: [],
        sync_interval: [],
        post_new_jobs: [],
        update_existing_jobs: [],
        delete_closed_jobs: [],
        custom_fields: {}
      }
    )
  end

  def ensure_company_access
    unless current_user.company_user? && current_user.company == @company
      redirect_to root_path, alert: "Access denied."
    end
  end
end
