class CompanySubscription < ApplicationRecord
  belongs_to :company
  belongs_to :subscription_plan

  enum :status, { trial: 'trial', active: 'active', expired: 'expired', canceled: 'canceled' }

  validates :status, presence: true
  validates :trial_start, presence: true, if: :trial?
  validates :trial_end, presence: true, if: :trial?

  before_create :set_trial_period
  after_create :set_company_trial_status

  scope :active, -> { where(status: 'active') }
  scope :trial, -> { where(status: 'trial') }
  scope :expired, -> { where(status: 'expired') }
  scope :expiring_soon, -> { where('expires_at <= ? AND expires_at > ?', 30.days.from_now, Time.current) }
  scope :expired_subscriptions, -> { where('expires_at <= ?', Time.current) }

  def trial_days_remaining
    return 0 unless trial_end
    remaining = (trial_end - Time.current).to_i / 1.day
    [remaining, 0].max
  end

  def in_trial_period?
    trial? && trial_end && trial_end > Time.current
  end

  def trial_expired?
    trial? && trial_end && trial_end <= Time.current
  end

  def subscription_expired?
    expires_at && expires_at <= Time.current
  end

  def subscription_expiring_soon?
    expires_at && expires_at <= 30.days.from_now && expires_at > Time.current
  end

  def days_until_expiry
    return nil unless expires_at
    remaining = (expires_at - Time.current).to_i / 1.day
    [remaining, 0].max
  end

  def subscription_days_remaining
    return trial_days_remaining if trial?
    days_until_expiry
  end

  def can_post_jobs?
    return true if subscription_plan.job_posting_limit == 0 # unlimited
    company.jobs.count < subscription_plan.job_posting_limit
  end

  def can_search_candidates?
    return true if subscription_plan.candidate_search_limit == 0 # unlimited
    # This would need to be tracked in a separate table or session
    true # For now, allow all searches
  end

  def has_analytics_access?
    subscription_plan.analytics_dashboard
  end

  def has_priority_support?
    subscription_plan.priority_support
  end

  def has_api_access?
    subscription_plan.api_access
  end

  def has_custom_branding?
    subscription_plan.custom_branding
  end

  def upgrade_to_plan(new_plan, duration_months: 1)
    return false unless new_plan.is_a?(SubscriptionPlan)
    
    # Set expiry date based on duration
    new_expires_at = Time.current + duration_months.months
    
    update(
      subscription_plan: new_plan,
      status: 'active',
      trial_start: nil,
      trial_end: nil,
      expires_at: new_expires_at
    )
  end

  def cancel_subscription
    update(status: 'canceled')
  end

  def reactivate_subscription
    update(status: 'active')
  end

  def expire_trial
    update(status: 'expired') if trial?
  end

  def extend_subscription(days)
    return false unless expires_at
    
    new_expires_at = expires_at + days.days
    update(expires_at: new_expires_at)
  end

  def renew_subscription(duration_months: 1)
    new_expires_at = Time.current + duration_months.months
    update(
      status: 'active',
      expires_at: new_expires_at
    )
  end

  private

  def set_trial_period
    return unless subscription_plan.trial_days > 0
    
    self.trial_start = Time.current
    self.trial_end = trial_start + subscription_plan.trial_days.days
    self.status = 'trial'
  end

  def set_company_trial_status
    company.update(trial_ends_at: trial_end) if trial_end
  end
end
