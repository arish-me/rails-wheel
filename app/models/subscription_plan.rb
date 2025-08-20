class SubscriptionPlan < ApplicationRecord
  has_many :company_subscriptions, dependent: :restrict_with_error
  has_many :companies, through: :company_subscriptions

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :trial_days, presence: true, numericality: { greater_than_or_equal_to: 0 }

  enum :tier, { bronze: "bronze", silver: "silver", gold: "gold" }

  before_save :set_default_features

  scope :active, -> { where(active: true) }
  scope :ordered_by_tier, -> { order(tier: :asc) }

  def display_price
    if price == 0
      "Free"
    else
      "₹#{price.to_i}"
    end
  end

  def monthly_price
    price
  end

  def yearly_price
    (price * 12 * 0.83).round # 2 months free
  end

  def display_yearly_price
    "₹#{yearly_price.to_i}/year"
  end

  def has_feature?(feature_name)
    features&.dig(feature_name.to_s) == true
  end

  def job_posting_limit
    features&.dig("job_posting_limit") || 0
  end

  def candidate_search_limit
    features&.dig("candidate_search_limit") || 0
  end

  def analytics_dashboard
    features&.dig("analytics_dashboard") == true
  end

  def priority_support
    features&.dig("priority_support") == true
  end

  def api_access
    features&.dig("api_access") == true
  end

  def custom_branding
    features&.dig("custom_branding") == true
  end

  private

  def set_default_features
    self.features ||= {}

    # Set default features based on tier
    case tier
    when "bronze"
      self.features = {
        "job_posting_limit" => 5,
        "candidate_search_limit" => 50,
        "analytics_dashboard" => false,
        "priority_support" => false,
        "api_access" => false,
        "custom_branding" => false
      }
    when "silver"
      self.features = {
        "job_posting_limit" => 15,
        "candidate_search_limit" => 200,
        "analytics_dashboard" => true,
        "priority_support" => false,
        "api_access" => false,
        "custom_branding" => false
      }
    when "gold"
      self.features = {
        "job_posting_limit" => 0, # unlimited
        "candidate_search_limit" => 0, # unlimited
        "analytics_dashboard" => true,
        "priority_support" => true,
        "api_access" => true,
        "custom_branding" => true
      }
    end
  end
end
