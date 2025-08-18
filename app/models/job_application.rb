class JobApplication < ApplicationRecord
  # ============================================================================
  # ASSOCIATIONS
  # ============================================================================

  belongs_to :job
  belongs_to :candidate
  belongs_to :user
  belongs_to :reviewed_by, class_name: "User", optional: true

  # Active Storage
  has_one_attached :resume

  # ============================================================================
  # VALIDATIONS
  # ============================================================================

  validates :job_id, uniqueness: { scope: :candidate_id, message: "You have already applied to this job" }
  validates :cover_letter, presence: true, length: { minimum: 50 }, unless: :is_quick_apply
  validates :portfolio_url, presence: true, if: :require_portfolio?
  validates :portfolio_url, format: { with: URI.regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
  validates :resume, presence: true, unless: :is_quick_apply

  # validates :resume, content_type: { in: ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'], message: 'must be a PDF, DOC, or DOCX file' }, if: :resume_attached?
  # validates :resume, size: { less_than: 10.megabytes, message: 'must be less than 10MB' }, if: :resume_attached?

  # ============================================================================
  # ENUMS
  # ============================================================================

  enum :status, {
    applied: "applied",
    reviewing: "reviewing",
    shortlisted: "shortlisted",
    interviewed: "interviewed",
    offered: "offered",
    rejected: "rejected",
    withdrawn: "withdrawn"
  }

  # ============================================================================
  # SCOPES
  # ============================================================================

  scope :recent, -> { order(applied_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_job, ->(job) { where(job: job) }
  scope :by_candidate, ->(candidate) { where(candidate: candidate) }
  scope :by_user, ->(user) { where(user: user) }
  scope :reviewed, -> { where.not(reviewed_at: nil) }
  scope :unreviewed, -> { where(reviewed_at: nil) }
  scope :quick_applies, -> { where(is_quick_apply: true) }
  scope :with_cover_letter, -> { where(is_quick_apply: false) }
  scope :with_applicant_details, -> { includes(:user, :candidate, :reviewed_by) }
  scope :with_job_details, -> { includes(:job) }

  # ============================================================================
  # CALLBACKS
  # ============================================================================

  before_create :set_applied_at
  after_update :set_reviewed_at, if: :status_changed?

  # ============================================================================
  # SEARCH
  # ============================================================================

  pg_search_scope :search_by_content,
                  against: [ :cover_letter, :additional_notes ],
                  using: {
                    tsearch: { prefix: true }
                  }

  # ============================================================================
  # CONSTANTS
  # ============================================================================

  STATUSES = statuses.keys.freeze

  # ============================================================================
  # STATUS METHODS
  # ============================================================================

  def applied?
    status == "applied"
  end

  def reviewing?
    status == "reviewing"
  end

  def shortlisted?
    status == "shortlisted"
  end

  def interviewed?
    status == "interviewed"
  end

  def offered?
    status == "offered"
  end

  def rejected?
    status == "rejected"
  end

  def withdrawn?
    status == "withdrawn"
  end

  def reviewed?
    reviewed_at.present?
  end

  def can_be_withdrawn?
    %w[applied reviewing shortlisted].include?(status)
  end

  def can_be_re_apply?
    %w[withdrawn].include?(status)
  end

  def can_be_reviewed?
    !reviewed? && !withdrawn?
  end

  # ============================================================================
  # DISPLAY METHODS
  # ============================================================================

  def display_status
    status&.titleize
  end

  def display_applied_date
    applied_at&.strftime("%B %d, %Y")
  end

  def display_reviewed_date
    reviewed_at&.strftime("%B %d, %Y")
  end

  def display_application_type
    is_quick_apply? ? "Quick Apply" : "Standard Application"
  end

  # ============================================================================
  # ACTION METHODS
  # ============================================================================

  def mark_as_reviewed!(reviewer)
    update!(
      reviewed_at: Time.current,
      reviewed_by: reviewer
    )
  end

  def withdraw!
    update!(status: "withdrawn") if can_be_withdrawn?
  end

  def increment_view_count!
    increment!(:view_count)
    update!(last_viewed_at: Time.current)
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

  # ============================================================================
  # PRIVATE METHODS
  # ============================================================================

  private

  def set_applied_at
    self.applied_at = Time.current
  end



  def set_reviewed_at
    return if reviewed_at.present?

    if %w[shortlisted interviewed offered rejected].include?(status)
      self.reviewed_at = Time.current
    end
  end

  def require_portfolio?
    job.require_portfolio
  end

  def resume_attached?
    resume.attached?
  end

  def has_cover_letter?
    cover_letter.present?
  end

  def has_resume?
    resume.attached?
  end

  def has_portfolio?
    portfolio_url.present?
  end

  def application_completeness
    completeness = 0
    completeness += 25 if has_cover_letter?
    completeness += 25 if has_resume?
    completeness += 25 if has_portfolio? || !require_portfolio?
    completeness += 25 if additional_notes.present?
    completeness
  end
end
