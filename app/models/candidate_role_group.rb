class CandidateRoleGroup < ApplicationRecord
  has_many :candidate_roles

  # Performance scopes
  scope :with_candidate_roles, -> { includes(:candidate_roles) }
end
