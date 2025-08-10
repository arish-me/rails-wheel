class Job < ApplicationRecord
  include RichText

  belongs_to :company
  belongs_to :created_by, class_name: 'User'
  has_many :job_applications, dependent: :destroy
  has_many :applicants, through: :job_applications, source: :candidate
  has_many :application_users, through: :job_applications, source: :user
  has_many :job_board_sync_logs, dependent: :destroy

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :description, presence: true, length: { minimum: 50 }
  validates :slug, presence: true, uniqueness: true
  validates :salary_min, numericality: { greater_than: 0 }, allow_nil: true
  validates :salary_max, numericality: { greater_than: 0 }, allow_nil: true
  validates :expires_at, presence: true, if: :published?

  # Enums
  enum :job_type, {
    full_time: 'full_time',
    part_time: 'part_time',
    contract: 'contract',
    freelance: 'freelance',
    internship: 'internship'
  }

  enum :experience_level, {
    entry: 'entry',
    junior: 'junior',
    mid: 'mid',
    senior: 'senior',
    lead: 'lead',
    executive: 'executive'
  }

  enum :remote_policy, {
    on_site: 'on_site',
    remote: 'remote',
    hybrid: 'hybrid'
  }

  enum :status, {
    draft: 'draft',
    published: 'published',
    closed: 'closed',
    archived: 'archived'
  }

  enum :salary_period, {
    hourly: 'hourly',
    daily: 'daily',
    weekly: 'weekly',
    monthly: 'monthly',
    yearly: 'yearly'
  }

  # Scopes
  scope :published, -> { where(status: 'published') }
  scope :active, -> { published.where('expires_at > ?', Time.current) }
  scope :featured, -> { where(featured: true) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :by_company, ->(company) { where(company: company) }
  scope :by_company_id, ->(company_id) { where(company_id: company_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_location, ->(location) { where('location ILIKE ?', "%#{location}%") }
  scope :by_job_type, ->(type) { where(job_type: type) }
  scope :by_experience_level, ->(level) { where(experience_level: level) }
  scope :by_remote_policy, ->(policy) { where(remote_policy: policy) }

  # Callbacks
  before_validation :generate_slug, on: :create
  before_save :set_published_at, if: :status_changed_to_published?
  after_save :update_company_job_count, if: :saved_change_to_status?

  # Search
  pg_search_scope :search_by_title_and_description,
                  against: [:title, :description, :requirements],
                  using: {
                    tsearch: { prefix: true }
                  }

  # Constants
  JOB_TYPES = job_types.keys.freeze
  EXPERIENCE_LEVELS = experience_levels.keys.freeze
  REMOTE_POLICIES = remote_policies.keys.freeze
  STATUSES = statuses.keys.freeze
  SALARY_PERIODS = salary_periods.keys.freeze

  # Display methods
  def display_salary
    return 'Salary not specified' if salary_min.blank? && salary_max.blank?

    if salary_min.present? && salary_max.present?
      "#{salary_currency} #{salary_min} - #{salary_max} #{salary_period}"
    elsif salary_min.present?
      "#{salary_currency} #{salary_min}+ #{salary_period}"
    else
      "#{salary_currency} Up to #{salary_max} #{salary_period}"
    end
  end

  def display_location
    [city, state, country].compact.join(', ')
  end

  def display_job_type
    job_type&.titleize
  end

  def display_experience_level
    experience_level&.titleize
  end

  def display_remote_policy
    remote_policy&.titleize
  end

  def display_status
    status&.titleize
  end

  # Status methods
  def published?
    status == 'published'
  end

  def draft?
    status == 'draft'
  end

  def closed?
    status == 'closed'
  end

  def archived?
    status == 'archived'
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def active?
    published? && !expired?
  end

  def can_be_applied_to?
    active? && applications_count < 1000 # Reasonable limit
  end

  # Application methods
  def has_applicant?(candidate)
    job_applications.exists?(candidate: candidate)
  end

  def application_for(candidate)
    job_applications.find_by(candidate: candidate)
  end

  def increment_views!
    increment!(:views_count)
  end

  def increment_applications!
    increment!(:applications_count)
  end

  # External integration methods
  def external_url
    return nil unless external_id.present? && external_source.present?

    case external_source
    when 'linkedin'
      "https://www.linkedin.com/jobs/view/#{external_id}"
    when 'indeed'
      "https://www.indeed.com/viewjob?jk=#{external_id}"
    else
      nil
    end
  end



  def generate_slug
    return if slug.present?

    base_slug = title.parameterize
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

  def set_published_at
    self.published_at = Time.current
  end

  def status_changed_to_published?
    status_changed? && status == 'published'
  end

  def update_company_job_count
    # This could be used for analytics or caching
    # For now, we'll just ensure the company has the job
    company.touch if company.present?
  end

  # Rich text methods for job content
  def rich_text_description
    return nil unless description

    @rich_text_description ||= markdown.render(description).strip
  end

  def requirements_rich_text
    return nil unless requirements

    @requirements_rich_text ||= markdown.render(requirements).strip
  end

  def benefits_rich_text
    return nil unless benefits

    @benefits_rich_text ||= markdown.render(benefits).strip
  end

  private

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(
      filter_html: true,
      hard_wrap: true,
      no_images: true,
      no_links: true,
      no_styles: true
    ), {
      disable_indented_code_blocks: true,
      fenced_code_blocks: true,
      highlight: false,
      strikethrough: true,
      superscript: true,
      underline: true
    })
  end
end
