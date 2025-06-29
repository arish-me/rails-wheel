class Candidate::WorkPreference < ApplicationRecord
  belongs_to :candidate
  enum :search_status, {
    actively_looking: 1,
    open: 2,
    not_interested: 3,
    invisible: 4
  }

  enum :role_type, {
    part_time_contract: 1,
    full_time_contract: 2,
    full_time_employment: 3
  }

  enum :role_level, {
    junior: 1,
    mid: 2,
    senior: 3,
    principal: 3,
    c_level: 3
  }
end
