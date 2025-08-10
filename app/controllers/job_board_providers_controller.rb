class JobBoardProvidersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tenant

  def index
    @providers = JobBoardProvider.active.ordered
  end

  def show
    @provider = JobBoardProvider.find(params[:id])
    @integrations = current_user.company.job_board_integrations.by_provider(@provider.slug) if current_user.company_user?
  end
end
