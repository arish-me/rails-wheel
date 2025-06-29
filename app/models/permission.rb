# frozen_string_literal: true

class Permission < ApplicationRecord
  default_scope { order(id: :desc) }
  pg_search_scope :search_by_name,
                against: :name,
                using: {
                  tsearch: { prefix: true } # Enables partial matches (e.g., "Admin" matches "Administrator")
                }

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions
end
