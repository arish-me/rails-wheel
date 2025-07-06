class CandidateRole < ApplicationRecord
  belongs_to :candidate_role_group
  has_many :candidates
end
