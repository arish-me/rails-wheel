class Candidate < ApplicationRecord
  belongs_to :user
  has_one :profile, class_name: 'Candidate::Profile', dependent: :destroy
end
