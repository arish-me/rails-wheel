class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable,
         :lockable, :timeoutable, :trackable, :confirmable,
         :omniauthable, omniauth_providers: %i[google_oauth2 github]
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :categories, dependent: :destroy
  belongs_to :company, optional: true
  has_many :notifications, as: :recipient, class_name: "Noticed::Notification"

  # after_create :assign_default_role

  attr_accessor :skip_password_validation
  attr_accessor :current_sign_in_ip_address

  accepts_nested_attributes_for :user_roles, allow_destroy: true

  has_one_attached :profile_image do |attachable|
    attachable.variant :thumbnail, resize_to_fill: [ 300, 300 ], convert: :webp, saver: { quality: 80 }
    attachable.variant :small, resize_to_fill: [ 72, 72 ], convert: :webp, saver: { quality: 80 }, preprocessed: true
  end
  validate :profile_image_size

  pg_search_scope :search_by_email,
              against: :email,
              using: {
                tsearch: { prefix: true } # Enables partial matches (e.g., "Admin" matches "Administrator")
              }
  enum :gender, [ :he_she, :him_her, :they_them, :other ]
  enum :theme, { system: 0, light: 1, dark: 2 }, default: :system
  enum :user_type, { company: 0, user: 1, platform_admin: 99 }

  GENDER_DISPLAY = {
    he_she: "He/Him",
    him_her: "Him/Her",
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

  def assign_default_role
    default_role = Role.fetch_default_role
    UserRole.create!(user: self, role: default_role) if default_role
  end

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  def can?(action, resource)
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

  protected

  def password_required?
    return false if skip_password_validation
    super
  end

  private

    def ensure_valid_profile_image
      return unless profile_image.attached?

      unless profile_image.content_type.in?(%w[image/jpeg image/png])
        errors.add(:profile_image, "must be a JPEG or PNG")
        profile_image.purge
      end
    end

    def profile_image_size
      if profile_image.attached? && profile_image.byte_size > 10.megabytes
        errors.add(:profile_image, :invalid_file_size, max_megabytes: 10)
      end
    end
end
