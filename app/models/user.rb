class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable,
         :lockable, :timeoutable, :trackable, :confirmable,
         :omniauthable, omniauth_providers: %i[google_oauth2 github]

  # Include DeviseInvitable::Inviter to allow users to send invitations
  include DeviseInvitable::Inviter

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

  attr_accessor :skip_password_validation
  attr_accessor :current_sign_in_ip_address
  attr_accessor :delete_profile_image
  attr_accessor :redirect_to, :email_required, :bio_required

  accepts_nested_attributes_for :user_roles, allow_destroy: true
  accepts_nested_attributes_for :location, allow_destroy: true
  accepts_nested_attributes_for :candidate, allow_destroy: true

  has_one_attached :profile_image do |attachable|
    attachable.variant :thumbnail, resize_to_fill: [ 300, 300 ], convert: :webp, saver: { quality: 80 }
    attachable.variant :small, resize_to_fill: [ 72, 72 ], convert: :webp, saver: { quality: 80 }, preprocessed: true
  end
  has_one_attached :cover_image

  validate :profile_image_size
  validates :first_name, presence: true, on: :update
  validates :last_name, presence: true, on: :update

  pg_search_scope :search_by_email,
              against: :email,
              using: {
                tsearch: { prefix: true } # Enables partial matches (e.g., "Admin" matches "Administrator")
              }
  enum :gender, [ :he_him, :she_her, :they_them, :other ]
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
         .where("permissions.name = ? AND permissions.resource = ?", action, resource)
         .exists?
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
    first_name.present? && last_name.present?
  end

  def attach_avatar(image_url)
    return if profile_image.attached? # Avoid re-downloading if avatar is already attached

    begin
      uri = URI.parse(image_url)
      avatar_file = uri.open
      profile_image.attach(io: avatar_file, filename: "avatar.jpg", content_type: avatar_file.content_type)
    rescue StandardError => e
      Rails.logger.error "Failed to attach avatar: #{e.message}"
    end
  end

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  def ensure_candidate
    if user?
      create_candidate
    end
  end

  def email_required?
    email_required
  end

  def location
    super || build_location
  end

  def assign_default_role
    # Only assign default role if user has a company
    return unless company.present?
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

  protected

  def password_required?
    return false if skip_password_validation
    super
  end

  private

    def profile_image_size
      if profile_image.attached? && profile_image.byte_size > 10.megabytes
        errors.add(:profile_image, :invalid_file_size, max_megabytes: 10)
      end
    end
end
