class CompanySubscription < ApplicationRecord
  belongs_to :company

  enum :status, { trial: 0, active: 1, expiring: 2, expired: 3 }

  validates :status, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  scope :active, -> { where(status: 'active') }
  scope :trial, -> { where(status: 'trial') }
  scope :expired, -> { where(status: 'expired') }
  scope :expiring, -> { where(status: 'expiring') }

  # Plan features as constants
  PLAN_FEATURES = {
    job_posting_limit: 0, # unlimited
    candidate_search_limit: 0, # unlimited
    analytics_dashboard: true,
    priority_support: true,
    api_access: true,
    custom_branding: true
  }.freeze

  def trial?
    status == 'trial'
  end

  def active?
    status == 'active'
  end

  def expired?
    status == 'expired'
  end

  def expiring?
    status == 'expiring'
  end

  def trial_expired?
    trial? && end_date <= Time.current
  end

  def subscription_expired?
    active? && end_date <= Time.current
  end

  def subscription_expiring_soon?
    active? && end_date <= 30.days.from_now && end_date > Time.current
  end

  def days_remaining
    return 0 unless end_date
    remaining = (end_date - Time.current).to_i / 1.day
    [remaining, 0].max
  end

  def trial_days_remaining
    return 0 unless trial? && end_date
    remaining = (end_date - Time.current).to_i / 1.day
    [remaining, 0].max
  end

  def can_post_jobs?
    true # Always true with unlimited plan
  end

  def can_search_candidates?
    true # Always true with unlimited plan
  end

  def has_feature?(feature_name)
    PLAN_FEATURES[feature_name.to_sym] == true
  end

  def job_posting_limit
    PLAN_FEATURES[:job_posting_limit]
  end

  def candidate_search_limit
    PLAN_FEATURES[:candidate_search_limit]
  end

  def analytics_dashboard
    PLAN_FEATURES[:analytics_dashboard]
  end

  def priority_support
    PLAN_FEATURES[:priority_support]
  end

  def api_access
    PLAN_FEATURES[:api_access]
  end

  def custom_branding
    PLAN_FEATURES[:custom_branding]
  end

  def price
    10 # Fixed price
  end

  def display_price
    "$#{price}/month"
  end

  def plan_name
    "Hiring Wheels Pro"
  end

  def plan_description
    "Complete hiring platform with unlimited job postings and candidate searches"
  end
end
