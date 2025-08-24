class Platform::JobBoardProvidersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_platform_admin_access
  before_action :set_job_board_provider, only: [ :show, :edit, :update, :destroy ]

  def index
    @job_board_providers = JobBoardProvider.all.order(:name)
  end

  def show
  end

  def new
    @job_board_provider = JobBoardProvider.new
  end

  def create
    @job_board_provider = JobBoardProvider.new(job_board_provider_params)

    if @job_board_provider.save
      redirect_to platform_job_board_provider_path(@job_board_provider), notice: "Job board provider was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @job_board_provider.update(job_board_provider_params)
      redirect_to platform_job_board_provider_path(@job_board_provider), notice: "Job board provider was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @job_board_provider.job_board_integrations.exists?
      redirect_to platform_job_board_providers_path, alert: "Cannot delete provider with active integrations."
    else
      @job_board_provider.destroy
      redirect_to platform_job_board_providers_path, notice: "Job board provider was successfully deleted."
    end
  end

  private

  def set_job_board_provider
    @job_board_provider = JobBoardProvider.find(params[:id])
  end

  def job_board_provider_params
    params.require(:job_board_provider).permit(
      :name, :slug, :description, :api_documentation_url,
      :auth_type, :base_url, :status, settings: {}
    )
  end

  def require_platform_admin_access
    unless current_user.platform_admin?
      redirect_to root_path, alert: "Access denied. Platform admin privileges required."
    end
  end
end
