# frozen_string_literal: true

class Role < ApplicationRecord
  acts_as_tenant(:company)
  default_scope { order(id: :desc) }

  scope :fetch_default_role, -> { find_by(is_default: true) }

  pg_search_scope :search_by_name,
                  against: :name,
                  using: {
                    tsearch: { prefix: true } # Enables partial matches (e.g., "Admin" matches "Administrator")
                  }

  validates :name, presence: true,
                   uniqueness: { scope: :company_id, case_sensitive: false, message: 'already exists for this company' }

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  belongs_to :company

  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions

  scope :excluding_super_admin, -> { where.not(name: 'SuperAdmin') }

  before_save :ensure_single_default, if: -> { is_default_changed? && is_default }

  def ensure_single_default
    Role.where.not(id: id).update_all(is_default: false)
  end
end
