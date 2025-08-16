class Public::JobsController < ApplicationController
  before_action :set_filters, only: [ :index ]
  before_action :set_job, only: [ :show ]

  def index
    @jobs = Job.published.active.includes(:company)

    # Apply filters
    @jobs = @jobs.search_by_title_and_description(@filters[:search]) if @filters[:search].present?
    @jobs = @jobs.by_job_type(@filters[:role_type]) if @filters[:role_type].present?
    @jobs = @jobs.by_experience_level(@filters[:role_level]) if @filters[:role_level].present?
    @jobs = @jobs.by_remote_policy(@filters[:remote_policy]) if @filters[:remote_policy].present?
    @jobs = @jobs.by_location(@filters[:location]) if @filters[:location].present?
    @jobs = @jobs.by_company_id(@filters[:company_id]) if @filters[:company_id].present?
    @jobs = @jobs.featured if @filters[:featured] == "true"

    # Sort
    case @filters[:sort]
    when "newest"
      @jobs = @jobs.order(published_at: :desc)
    when "oldest"
      @jobs = @jobs.order(published_at: :asc)
    when "salary_high"
      @jobs = @jobs.order(salary_max: :desc)
    when "salary_low"
      @jobs = @jobs.order(salary_min: :asc)
    when "applications"
      @jobs = @jobs.order(applications_count: :desc)
    else
      @jobs = @jobs.order(published_at: :desc) # Default: newest first
    end

    @pagy, @jobs = pagy(@jobs, items: 12)

    # For filters
    @companies = Company.joins(:jobs).where(jobs: { status: "published" }).distinct.order(:name)
    @locations = Job.published.active.where.not(location: [ nil, "" ]).distinct.pluck(:location).compact.sort
  end

  def show
    @job.increment_views!
    @related_jobs = Job.published.active
                       .includes(:company)
                       .where.not(id: @job.id)
                       .where(company: @job.company)
                       .or(Job.published.active.where(role_type: @job.role_type))
                       .limit(3)
  end

  def search
    redirect_to public_jobs_path(search: params[:search])
  end

  private

  def set_job
    @job = Job.published.active.includes(:company).friendly.find(params[:id])
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
