class Candidate < ApplicationRecord
  belongs_to :user
  has_one :profile, class_name: "Candidate::Profile", dependent: :destroy
  has_one :work_preference, class_name: "Candidate::WorkPreference", dependent: :destroy
  has_one :role_type, class_name: "RoleType", dependent: :destroy
  has_one :role_level, class_name: "RoleLevel", dependent: :destroy

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :work_preference
  accepts_nested_attributes_for :role_level, update_only: true
  accepts_nested_attributes_for :role_type, update_only: true
end
