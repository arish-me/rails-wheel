class Job < ApplicationRecord
  extend FriendlyId

  friendly_id :slug_candidates, use: :slugged
  has_rich_text :description
  belongs_to :company
  belongs_to :created_by, class_name: "User"

  # Associations
  has_many :job_applications, dependent: :destroy, counter_cache: :job_applications_count
  has_many :applicants, through: :job_applications, source: :candidate
  has_many :application_users, through: :job_applications, source: :user
  has_many :job_board_sync_logs, dependent: :destroy
  has_many :specializations, as: :specializable, dependent: :destroy
  has_many :candidate_roles, through: :specializations
  has_many :job_skills, dependent: :destroy
  has_many :skills, through: :job_skills
  has_one :location, as: :locatable, dependent: :destroy

  accepts_nested_attributes_for :location, allow_destroy: true

  # Enums
  enum :remote_policy, {
    on_site: "on_site",
    remote: "remote",
    hybrid: "hybrid"
  }

  enum :status, {
    draft: "draft",
    published: "published",
    closed: "closed",
    expired: "expired",
    archived: "archived"
  }

  enum :salary_period, {
    hourly: "hourly",
    daily: "daily",
    weekly: "weekly",
    monthly: "monthly",
    yearly: "yearly"
  }

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :description, presence: true, length: { minimum: 50 }
  validates :slug, presence: true, uniqueness: true
  validates :salary_min, numericality: { greater_than: 0 }, allow_nil: true
  validates :salary_max, numericality: { greater_than: 0 }, allow_nil: true
  validates :expires_at, presence: true, if: :published?
  validate :salary_range_validity
  validate :location_required_unless_worldwide

  # Callbacks
  before_save :set_published_at, if: :status_changed_to_published?
  after_save :update_company_job_count, if: :saved_change_to_status?


  # Search
  pg_search_scope :search_by_title_and_description,
                  against: [ :title, :description, :requirements ],
                  using: { tsearch: { prefix: true } }

  # Constants
  REMOTE_POLICIES = remote_policies.keys.freeze
  STATUSES = statuses.keys.freeze
  SALARY_PERIODS = salary_periods.keys.freeze
  MAX_APPLICATIONS = 1000

  # ============================================================================
  # SCOPES
  # ============================================================================

  # Status scopes
  scope :published, -> { where(status: "published") }
  scope :active, -> { published.where("expires_at > ?", Time.current) }
  scope :expired, -> { where(status: "expired") }
  scope :expired_by_date, -> { where("expires_at <= ?", Time.current) }
  scope :draft, -> { where(status: "draft") }
  scope :closed, -> { where(status: "closed") }
  scope :archived, -> { where(status: "archived") }

  # Feature scopes
  scope :featured, -> { where(featured: true) }
  scope :not_featured, -> { where(featured: false) }

  # Company scopes
  scope :by_company, ->(company) { where(company: company) }
  scope :by_company_id, ->(company_id) { where(company_id: company_id) }

  # Location scopes
  scope :by_location, ->(location) { where("location ILIKE ?", "%#{location}%") }
  scope :worldwide, -> { where(worldwide: true) }
  scope :not_worldwide, -> { where(worldwide: false) }

  # Job type scopes
  scope :by_job_type, ->(type) { where(job_type: type) }
  scope :by_experience_level, ->(level) { where(experience_level: level) }
  scope :by_remote_policy, ->(policy) { where(remote_policy: policy) }

  # Ordering scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :newest_first, -> { order(published_at: :desc) }
  scope :oldest_first, -> { order(published_at: :asc) }
  scope :salary_high_to_low, -> { order(salary_max: :desc) }
  scope :salary_low_to_high, -> { order(salary_min: :asc) }
  scope :most_applications, -> { order(job_applications_count: :desc) }
  scope :most_views, -> { order(views_count: :desc) }

  # Performance scopes
  scope :with_company, -> { includes(:company) }
  scope :with_applications, -> { includes(:job_applications) }
  scope :with_location, -> { includes(:location) }
  scope :with_skills, -> { includes(:skills) }
  scope :with_candidate_roles, -> { includes(:candidate_roles) }

  # ============================================================================
  # STATUS METHODS
  # ============================================================================

  def published?
    status == "published"
  end

  def draft?
    status == "draft"
  end

  def closed?
    status == "closed"
  end

  def expired?
    status == "expired"
  end

  def archived?
    status == "archived"
  end

  def past_expiration_date?
    expires_at.present? && expires_at <= Time.current
  end

  def active?
    published? && !past_expiration_date?
  end

  def can_be_applied_to?
    active? && applications_count < MAX_APPLICATIONS
  end

  def can_be_published?
    (draft? || closed?) && valid_for_publication?
  end

  def can_be_closed?
    published? || draft?
  end

  def location
    super || build_location
  end

  # ============================================================================
  # DISPLAY METHODS
  # ============================================================================

  def display_salary
    return "Salary not specified" if salary_min.blank? && salary_max.blank?

    if salary_min.present? && salary_max.present?
      "#{salary_currency} #{salary_min} - #{salary_max} #{salary_period}"
    elsif salary_min.present?
      "#{salary_currency} #{salary_min}+ #{salary_period}"
    else
      "#{salary_currency} Up to #{salary_max} #{salary_period}"
    end
  end

  def display_location
    [ city, state, country ].compact.join(", ")
  end

  def display_job_type
    role_type&.titleize
  end

  def display_experience_level
    role_level&.titleize
  end

  def display_remote_policy
    remote_policy&.titleize
  end

  def display_status
    status&.titleize
  end

  def worldwide?
    worldwide == true
  end

  def display_location_or_worldwide
    if worldwide?
      "Worldwide"
    else
      display_location.presence || "Location not specified"
    end
  end

  # ============================================================================
  # APPLICATION METHODS
  # ============================================================================

  def has_applicant?(candidate)
    job_applications.exists?(candidate_id: candidate.id)
  end

  def application_for(candidate)
    job_applications.find_by(candidate: candidate)
  end

  def applications_count
    job_applications_count
  end

  def recent_applications(limit: 5)
    job_applications.includes(:candidate, :user).recent.limit(limit)
  end

  # ============================================================================
  # COUNTER METHODS
  # ============================================================================

  def increment_views!
    increment!(:views_count)
  end

  def increment_applications!
    increment!(:job_applications_count)
  end

  # ============================================================================
  # EXTERNAL INTEGRATION METHODS
  # ============================================================================

  def external_url
    return nil unless external_id.present? && external_source.present?

    case external_source
    when "linkedin"
      "https://www.linkedin.com/jobs/view/#{external_id}"
    when "indeed"
      "https://www.indeed.com/viewjob?jk=#{external_id}"
    else
      nil
    end
  end

  def has_external_source?
    external_id.present? && external_source.present?
  end

  # ============================================================================
  # SLUG METHODS
  # ============================================================================

  def slug_candidates
    [ [ :title, :company_name, :id ] ]
  end

  def company_name
    company&.name&.parameterize || "company"
  end

  def generate_slug
    return if slug.present?

    base_slug = "#{title.parameterize}-#{company_name}"
    counter = 0

    loop do
      candidate_slug = counter.zero? ? base_slug : "#{base_slug}-#{counter}"
      unless Job.exists?(slug: candidate_slug)
        self.slug = candidate_slug
        break
      end
      counter += 1
    end
  end

  # ============================================================================
  # RELATED JOBS METHODS
  # ============================================================================

  def related_jobs(limit: 3)
    Job.published.active
       .with_company
       .where.not(id: id)
       .where(company: company)
       .or(Job.published.active.where(role_type: role_type))
       .limit(limit)
  end

  # ============================================================================
  # CLASS METHODS
  # ============================================================================

  def self.expire_expired_jobs
    expired_jobs = published.where('expires_at <= ?', Time.current)

    if expired_jobs.any?
      expired_jobs.update_all(status: 'expired', updated_at: Time.current)
      Rails.logger.info "Expired #{expired_jobs.count} jobs"
    end

    expired_jobs.count
  end

  # ============================================================================
  # PRIVATE METHODS
  # ============================================================================

  private

  def set_published_at
    self.published_at = Time.current
  end

  def status_changed_to_published?
    status_changed? && status == "published"
  end

  def update_company_job_count
    company.touch if company.present?
  end

  def salary_range_validity
    return if salary_min.blank? || salary_max.blank?

    if salary_min > salary_max
      errors.add(:salary_max, "must be greater than minimum salary")
    end
  end

  def location_required_unless_worldwide
    return if worldwide?

    location_present = location&.location_search.present? ||
                      city.present? ||
                      state.present? ||
                      country.present?

    unless location_present
      errors.add(:base, "Location is required unless the job is marked as worldwide")
    end
  end

  def valid_for_publication?
    title.present? &&
    description.present? &&
    expires_at.present? &&
    expires_at > Time.current &&
    (worldwide? || location_present?)
  end

  def location_present?
    location&.location_search.present? ||
    city.present? ||
    state.present? ||
    country.present?
  end
end
