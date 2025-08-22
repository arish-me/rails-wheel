class User < ApplicationRecord
  include Avatarable

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable,
         :lockable, :timeoutable, :trackable, :confirmable,
         :omniauthable, omniauth_providers: %i[google_oauth2]

  # Include DeviseInvitable::Inviter to allow users to send invitations
  include DeviseInvitable::Inviter

  # def self.avatar_validation_context
  #  :update
  # end
  belongs_to :company, optional: true
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :categories, dependent: :destroy
  has_many :notifications, as: :recipient, class_name: "Noticed::Notification"
  has_many :invitations, class_name: "User", as: :invited_by
  has_many :created_jobs, class_name: "Job", foreign_key: "created_by_id", dependent: :destroy
  has_many :job_applications, dependent: :destroy
  has_many :reviewed_applications, class_name: "JobApplication", foreign_key: "reviewed_by_id"

  has_one :candidate, dependent: :destroy, class_name: "Candidate"
  has_one :location, as: :locatable, dependent: :destroy
  after_create :ensure_candidate
  after_invitation_accepted :setup_invited_user
  attr_accessor :skip_password_validation, :current_sign_in_ip_address, :delete_profile_image, :redirect_to,
                :email_required, :bio_required, :in_onboarding_context

  accepts_nested_attributes_for :user_roles, allow_destroy: true
  accepts_nested_attributes_for :location, allow_destroy: true
  accepts_nested_attributes_for :candidate, allow_destroy: true

  after_update :handle_user_type_change, if: :saved_change_to_user_type?

  validates :first_name, presence: true, on: :update, if: :should_validate_names?
  validates :last_name, presence: true, on: :update, if: :should_validate_names?
  validates :email, presence: true, email: true
  validate :company_email_validation, if: :company_user?
  # validate :onboarding_name_validation, if: :onboarding_context?

  pg_search_scope :search_by_email,
                  against: :email,
                  using: {
                    tsearch: { prefix: true } # Enables partial matches (e.g., "Admin" matches "Administrator")
                  }
  enum :gender, { he_him: 0, she_her: 1, they_them: 2, other: 3 }
  enum :user_type, { company: 0, user: 1, platform_admin: 99 }

  GENDER_DISPLAY = {
    he_him: "He/Him",
    she_her: "She/Her",
    they_them: "They/Them",
    other: "Other"
  }.freeze

  DATE_FORMATS = [
    [ "MM-DD-YYYY", "%m-%d-%Y" ],
    [ "DD.MM.YYYY", "%d.%m.%Y" ],
    [ "DD-MM-YYYY", "%d-%m-%Y" ],
    [ "YYYY-MM-DD", "%Y-%m-%d" ],
    [ "DD/MM/YYYY", "%d/%m/%Y" ],
    [ "YYYY/MM/DD", "%Y/%m/%d" ],
    [ "MM/DD/YYYY", "%m/%d/%Y" ],
    [ "D/MM/YYYY", "%e/%m/%Y" ],
    [ "YYYY.MM.DD", "%Y.%m.%d" ]
  ].freeze

  def lock_access!
    update_columns(locked_at: Time.current, failed_attempts: 0)
  end

  def can?(action, resource)
    ActsAsTenant.current_tenant = Company.find(company_id)
    roles.joins(:role_permissions)
         .joins("INNER JOIN permissions ON permissions.id = role_permissions.permission_id")
         .exists?([ "permissions.name = ? AND permissions.resource = ?", action, resource ])
  end

  def display_name
    [ first_name, last_name ].compact.join(" ").presence || email
  end

  def initial
    (display_name&.first || email.first).upcase
  end

  def initials
    if first_name.present? && last_name.present?
      "#{first_name.first}#{last_name.first}".upcase
    else
      initial
    end
  end

  def onboarded?
    onboarded_at.present?
  end

  def needs_onboarding?
    !onboarded?
  end

  def missing_fields?
    first_name.present? && last_name.present? && avatar.attached? && location.valid?
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

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  def ensure_candidate
    return unless user? && candidate.blank?

    create_candidate
  end

  def email_required?
    email_required
  end

  def location
    super || build_location
  end

  def assign_default_role
    # Only assign default role if user has a company
    return if company.blank?

    ActsAsTenant.current_tenant = company
    default_role = company.roles.fetch_default_role
    # Find the default role for the company or create one if it doesn't exist
    # default_role = Role.find_or_create_by(name: 'User', company: company) do |role|
    #   role.description = 'Default user role'
    # end

    # Assign the default role to the user
    user_roles.create(role: default_role) unless roles.include?(default_role)
  end

  def setup_invited_user
    # Set company from the inviter if not already set and inviter has a company
    if invited_by.present? && company_id.blank? && invited_by.company_id.present?
      update_columns(company_id: invited_by.company_id, active: true)
    end

    # Set user type to company for invited users
    update_columns(user_type: "company") if user_type.blank?

    # Skip onboarding for invited users
    update_columns(onboarded_at: Time.current) if onboarded_at.blank?

    # Ensure candidate is created
    ensure_candidate
  end

  def can_be_invited?
    # Platform admins cannot be invited
    return false if platform_admin?

    # Users with pending invitations cannot be invited again
    return false if invitation_sent_at.present? && invitation_accepted_at.blank?

    # Users who have already accepted invitations cannot be invited again
    return false if invitation_accepted_at.present?

    # Users who are already active members cannot be invited
    return false if active? && company_id.present?

    true
  end

  def invitation_status
    if invitation_accepted_at.present?
      "accepted"
    elsif invitation_sent_at.present?
      "pending"
    elsif active?
      "active"
    else
      "created"
    end
  end

  def oauth_user?
    provider.present? && uid.present?
  end

  def needs_profile_completion?
    oauth_user? && (first_name.blank? || last_name.blank? || first_name == "User" || last_name == "User")
  end

  def company_user?
    user_type == "company"
  end

  def personal_user?
    user_type == "user"
  end

  def has_candidate_profile?
    candidate.present?
  end

  def has_complete_basic_profile?
    first_name.present? && last_name.present?
  end

  def should_validate_names?
    # Always validate names for non-OAuth users
    return true unless oauth_user?

    # For OAuth users, validate names during onboarding
    # This means when they're still in the onboarding process
    needs_onboarding?
  end

  def onboarding_context?
    # Check if we're in an onboarding context
    # This can be determined by checking if we're on onboarding pages
    # or if the user is still in the onboarding process
    in_onboarding_context == true || needs_onboarding?
  end

  private

  def company_email_validation
    return if email.blank?

    validation_result = EmailDomainValidator.validate_company_email(email)
    return if validation_result[:valid]

    errors.add(:email, validation_result[:message])
  end

  def handle_user_type_change
    if user_type == "user"
      # User changed to 'user' type - create candidate if it doesn't exist
      if candidate.present?
        Rails.logger.info "User #{id} already has candidate record, skipping creation"
      else
        create_candidate
        Rails.logger.info "Created candidate record for user #{id}"
      end
    elsif user_type == "company"
      # User changed to 'company' type - destroy candidate if it exists
      if candidate.present?
        candidate.destroy
        Rails.logger.info "Destroyed candidate record for user #{id}"
      else
        Rails.logger.info "User #{id} has no candidate record to destroy"
      end
    end
  end

  def onboarding_name_validation
    # During onboarding, require names for all users (including OAuth users)
    errors.add(:first_name, "is required to complete your profile") if first_name.blank?

    return if last_name.present?

    errors.add(:last_name, "is required to complete your profile")
  end

  protected

  def password_required?
    return false if skip_password_validation

    super
  end

  private

  def profile_image_size
    return unless avatar.attached? && avatar.byte_size > 10.megabytes

    errors.add(:avatar, :invalid_file_size, max_megabytes: 10)
  end
end
