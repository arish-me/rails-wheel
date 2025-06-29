class Candidate < ApplicationRecord
  belongs_to :user
  has_one :profile, class_name: "Candidate::Profile", dependent: :destroy
  has_one :work_preference, class_name: "Candidate::WorkPreference", dependent: :destroy

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :work_preference
end
