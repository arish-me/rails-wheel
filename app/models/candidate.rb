class Candidate < ApplicationRecord
  include Hashid::Rails

  attr_accessor :redirect_to

  belongs_to :user
  belongs_to :candidate_role, optional: true
  has_one :profile, class_name: "Candidate::Profile", dependent: :destroy
  has_one :work_preference, class_name: "Candidate::WorkPreference", dependent: :destroy
  has_one :role_type, class_name: "RoleType", through: :work_preference, dependent: :destroy
  has_one :role_level, class_name: "RoleLevel", through: :work_preference, dependent: :destroy

  has_one :social_link, as: :linkable, dependent: :destroy
  has_one :location, as: :locatable, dependent: :destroy, autosave: true
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :work_preference
end
