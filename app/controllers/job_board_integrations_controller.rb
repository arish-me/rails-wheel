class JobBoardIntegrationsController < ApplicationController
  before_action :authenticate_user!
  # before_action :set_tenant
  before_action :set_integration, only: [ :show, :edit, :update, :destroy, :test_connection, :sync_job ]
  before_action :ensure_company_user

  def index
    @integrations = current_user.company.job_board_integrations.includes(:job_board_provider).ordered
    @providers = JobBoardProvider.active.ordered
  end

  def show
    @sync_logs = @integration.job_board_sync_logs.includes(:job).recent.limit(20)
  end

  def new
    @integration = current_user.company.job_board_integrations.build
    @providers = JobBoardProvider.active.ordered
  end

  def create
    @integration = current_user.company.job_board_integrations.build(integration_params)
    @providers = JobBoardProvider.active.ordered

    respond_to do |format|
      if @integration.save
        format.html { redirect_to @integration, notice: "Job board integration was successfully created." }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect(@integration) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("integration_form", partial: "form") }
      end
    end
  end

  def edit
    @providers = JobBoardProvider.active.ordered
  end

  def update
    @providers = JobBoardProvider.active.ordered

    respond_to do |format|
      if @integration.update(integration_params)
        format.html { redirect_to @integration, notice: "Job board integration was successfully updated." }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect(@integration) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("integration_form", partial: "form") }
      end
    end
  end

  def destroy
    @integration.destroy

    respond_to do |format|
      format.html { redirect_to job_board_integrations_path, notice: "Job board integration was successfully deleted." }
      format.turbo_stream { render turbo_stream: turbo_stream.redirect(job_board_integrations_path) }
    end
  end

  def test_connection
    success = @integration.test_connection

    respond_to do |format|
      if success
        format.html { redirect_to @integration, notice: "Connection test successful!" }
        # format.turbo_stream { render turbo_stream: turbo_stream.redirect(@integration) }
      else
        format.html { redirect_to @integration, alert: "Connection test failed. Check the logs for details." }
        # format.turbo_stream { render turbo_stream: turbo_stream.redirect(@integration) }
      end
    end
  end

  def sync_job
    job = Job.find(params[:job_id])
    success = @integration.sync_job(job)

    respond_to do |format|
      if success
        format.html { redirect_to @integration, notice: "Job '#{job.title}' was successfully synced." }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect(@integration) }
      else
        format.html { redirect_to @integration, alert: "Failed to sync job '#{job.title}'. Check the logs for details." }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect(@integration) }
      end
    end
  end

  private

  def set_integration
    @integration = current_user.company.job_board_integrations.find(params[:id])
  end

  def ensure_company_user
    # unless current_user.company?
    #   redirect_to dashboard_path, alert: 'You must be a company user to manage job board integrations.'
    # end
  end

  def integration_params
    params.require(:job_board_integration).permit(
      :name, :provider, :api_key, :api_secret, :webhook_url, :status,
      settings: {}
    )
  end
end
