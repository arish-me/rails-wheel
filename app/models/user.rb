class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :profile, dependent: :destroy
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :categories, dependent: :destroy

  attr_accessor :skip_password_validation

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  def can?(action, resource)
    roles.joins(:role_permissions)
         .joins('INNER JOIN permissions ON permissions.id = role_permissions.permission_id')
         .where('permissions.name = ? AND permissions.resource = ?', action, resource)
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
