class Candidate::WorkPreference < ApplicationRecord
  belongs_to :candidate
  enum :search_status, {
    actively_looking: 1,
    open: 2,
    not_interested: 3,
    invisible: 4
  }
end
