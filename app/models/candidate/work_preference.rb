class Candidate::WorkPreference < ApplicationRecord
  belongs_to :candidate

  # Direct associations to role_type and role_level
  has_one :role_type, class_name: "RoleType", dependent: :destroy
  has_one :role_level, class_name: "RoleLevel", dependent: :destroy

  # Accept nested attributes for role_type and role_level
  accepts_nested_attributes_for :role_type, update_only: true
  accepts_nested_attributes_for :role_level, update_only: true

  enum :search_status, {
    actively_looking: 1,
    open: 2,
    not_interested: 3,
    invisible: 4
  }

  validates :search_status, presence: true

  # Delegate to candidate for convenience
  delegate :user, to: :candidate, allow_nil: true

  # Build role_type and role_level if they don't exist
  def ensure_role_associations
    build_role_type unless role_type
    build_role_level unless role_level
  end
end
