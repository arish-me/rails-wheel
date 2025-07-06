class Candidate < ApplicationRecord
  include Hashid::Rails

  belongs_to :user
  belongs_to :candidate_role, optional: true
  has_one :profile, class_name: "Candidate::Profile", dependent: :destroy
  has_one :work_preference, class_name: "Candidate::WorkPreference", dependent: :destroy
  has_one :role_type, class_name: "RoleType", dependent: :destroy
  has_one :role_level, class_name: "RoleLevel", dependent: :destroy
  has_one :social_link, as: :linkable, dependent: :destroy
  has_one :location, as: :locatable, dependent: :destroy, autosave: true
  accepts_nested_attributes_for :user
  # accepts_nested_attributes_for :profile
  # accepts_nested_attributes_for :work_preference
  # accepts_nested_attributes_for :candidate_role
  # accepts_nested_attributes_for :role_level, update_only: true
  #accepts_nested_attributes_for :role_type, update_only: true
  #accepts_nested_attributes_for :social_link, allow_destroy: true, reject_if: :all_blank
  #accepts_nested_attributes_for :location, reject_if: :all_blank, update_only: true
end
