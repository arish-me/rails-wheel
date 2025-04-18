class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable, :trackable, :confirmable, :lockable, :timeoutable,
         :omniauthable, omniauth_providers: %i[google_oauth2 github]
  has_one :profile, dependent: :destroy
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :categories, dependent: :destroy

  after_create :assign_default_role

  attr_accessor :skip_password_validation

  accepts_nested_attributes_for :profile, update_only: true
  accepts_nested_attributes_for :user_roles, allow_destroy: true

  pg_search_scope :search_by_email,
              against: :email,
              using: {
                tsearch: { prefix: true } # Enables partial matches (e.g., "Admin" matches "Administrator")
              }

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

  def initial
    (profile&.display_name&.first || email.first).upcase
  end

  protected

  def password_required?
    return false if skip_password_validation
    super
  end
end
