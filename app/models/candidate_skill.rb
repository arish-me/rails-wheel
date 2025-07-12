class CandidateSkill < ApplicationRecord
  belongs_to :candidate
  belongs_to :skill
end
