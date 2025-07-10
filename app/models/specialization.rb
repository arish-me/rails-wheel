class Specialization < ApplicationRecord
  belongs_to :specializable, polymorphic: true
  belongs_to :candidate_role
end
