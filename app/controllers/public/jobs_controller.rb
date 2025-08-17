class Public::JobsController < ApplicationController
  include JobFilterable

  before_action :set_filters, only: [:index]
  before_action :set_job, only: [:show]

  # ============================================================================
  # ACTIONS
  # ============================================================================

  def index
    @jobs = JobService.search_jobs(@filters)
    @pagy, @jobs = pagy(@jobs, items: 12)
    load_filter_options
  end

  def show
    @job_service = JobService.new(@job)
    @job_service.increment_views!
    @related_jobs = @job_service.find_related_jobs
  end

  def search
    redirect_to public_jobs_path(search: params[:search])
  end

  # ============================================================================
  # PRIVATE METHODS
  # ============================================================================

  private

  def set_job
    @job = Job.published.active.with_company.friendly.find(params[:id])
  end

  def set_filters
    @filters = {
      search: params[:search],
      job_type: params[:job_type],
      experience_level: params[:experience_level],
      remote_policy: params[:remote_policy],
      location: params[:location],
      company_id: params[:company_id],
      featured: params[:featured],
      sort: params[:sort] || "newest"
    }
  end
end
