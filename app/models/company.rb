class Company < ApplicationRecord
 include Avatarable
 include Candidates::HasOnlineProfiles
 attr_accessor :redirect_to, :delete_avatar_image

 # Override avatar validation for Company model - require on create
 validates :avatar, attached: true, on: :create
 validates :name, presence: true, uniqueness: { case_sensitive: false }
 validates :subdomain, presence: true, uniqueness: { case_sensitive: false }
 validates :website, presence: true, uniqueness: { case_sensitive: false }

 after_create :assign_default_roles
 after_create :create_trial_subscription

 has_many :users, dependent: :destroy
 has_many :user_roles, dependent: :destroy
 has_many :roles, through: :user_roles
 has_many :roles, dependent: :destroy
 has_many :role_permissions, through: :roles
 has_many :categories
 has_many :jobs, dependent: :destroy
 has_many :job_applications, through: :jobs
 has_many :job_board_integrations, dependent: :destroy
 has_many :company_subscriptions, dependent: :destroy

 has_one :active_subscription, -> { active }, class_name: "CompanySubscription"

 pg_search_scope :search_by_name,
                against: :name,
                using: {
                  tsearch: { prefix: true }
                }

 accepts_nested_attributes_for :users

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
  def has_active_subscription?
    active_subscription.present?
  end

  def subscription_status
    return "no_subscription" unless active_subscription
    active_subscription.status
  end

  def subscription_plan
    active_subscription&.subscription_plan
  end

  def can_post_jobs?
    return true unless active_subscription
    active_subscription.can_post_jobs?
  end

  def can_search_candidates?
    return true unless active_subscription
    active_subscription.can_search_candidates?
  end

  def primary_contact_email
    users.first&.email
  end

  def phone_number
    users.first&.phone_number
  end

  private

  def create_trial_subscription
    # Only create trial if no subscriptions exist
    return if company_subscriptions.exists?
    SubscriptionService.create_trial_subscription(self)
  end
end
