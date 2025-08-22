module Public
  class JobsController < ApplicationController
    include JobFilterable

    before_action :set_filters, only: [:index]
    before_action :set_job, only: [:show]

    # ============================================================================
    # ACTIONS
    # ============================================================================

    def index
      @jobs = JobService.search_jobs(@filters)

      # Limit to 5 jobs for non-logged-in users
      if user_signed_in?
        @pagy, @jobs = pagy(@jobs, items: 12)
      else
        @jobs = @jobs.limit(5)
        @show_trial_cta = true
      end

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
        sort: params[:sort] || 'newest'
      }
    end
  end
end
