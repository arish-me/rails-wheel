class Company < ApplicationRecord
  include Avatarable
  include Candidates::HasOnlineProfiles

  attr_accessor :redirect_to, :delete_avatar_image

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :subdomain, presence: true, uniqueness: { case_sensitive: false }
  validates :website, presence: true, uniqueness: { case_sensitive: false }
  after_create :assign_default_roles
  after_create :create_trial_subscription
  has_many :users, dependent: :destroy
  has_many :user_roles, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :role_permissions, through: :roles
  # has_many :roles, through: :user_roles
  # has_many :categories, dependent: :destroy
  has_many :jobs, dependent: :destroy
  has_many :job_applications, through: :jobs
  has_many :job_board_integrations, dependent: :destroy
  has_one :company_subscription, dependent: :destroy

  pg_search_scope :search_by_name,
                  against: :name,
                  using: {
                    tsearch: { prefix: true }
                  }

  accepts_nested_attributes_for :users

  # Override avatar validation for Company model - require on create
  validates :avatar, attached: true, on: :create

  def assign_default_roles
    ActsAsTenant.with_tenant(self) do
      SeedData::MainSeeder.new(seed_user: false).seed_initial_data
    end
  end

  def attach_avatar(image_url)
    return if avatar.attached? # Avoid re-downloading if avatar is already attached

    begin
      uri = URI.parse(image_url)
      avatar_file = uri.open
      avatar.attach(io: avatar_file, filename: "avatar.jpg", content_type: avatar_file.content_type)
    rescue StandardError => e
      Rails.logger.error "Failed to attach avatar: #{e.message}"
    end
  end

  # Subscription methods
  def has_subscription?
    company_subscription.present?
  end

  def subscription_status
    return "no_subscription" unless company_subscription

    company_subscription.status
  end

  def can_post_jobs?
    return true unless company_subscription

    company_subscription.can_post_jobs?
  end

  def can_search_candidates?
    return true unless company_subscription

    company_subscription.can_search_candidates?
  end

  def primary_contact_email
    users.first&.email
  end

  def phone_number
    users.first&.phone_number
  end

  def create_trial_subscription
    return if company_subscription.present?

    create_company_subscription!(
      status: "trial",
      start_date: Time.current,
      end_date: 30.days.from_now
    )
  end

  def upgrade_to_paid_subscription(duration_months: 1)
    if company_subscription.present?
      # Update existing subscription
      company_subscription.update!(
        status: "active",
        start_date: Time.current,
        end_date: Time.current + duration_months.months
      )
    else
      # Create new paid subscription
      create_company_subscription!(
        status: "active",
        start_date: Time.current,
        end_date: Time.current + duration_months.months
      )
    end
  end
end
