class Candidate < ApplicationRecord
  include Hashid::Rails

  attr_accessor :redirect_to

  belongs_to :user
  # belongs_to :candidate_role, optional: true
  has_one :profile, class_name: "Candidate::Profile", dependent: :destroy
  has_one :work_preference, class_name: "Candidate::WorkPreference", dependent: :destroy
  has_one :role_type, class_name: "RoleType", through: :work_preference, dependent: :destroy
  has_one :role_level, class_name: "RoleLevel", through: :work_preference, dependent: :destroy

  has_one :social_link, as: :linkable, dependent: :destroy
  has_one :location, as: :locatable, dependent: :destroy, autosave: true
  accepts_nested_attributes_for :user
  # accepts_nested_attributes_for :work_preference
  has_many :specializations, as: :specializable, dependent: :destroy
  has_many :candidate_roles, through: :specializations
  accepts_nested_attributes_for :specializations, allow_destroy: true

  validate :specialization_count_within_bounds

  def specialization_count_within_bounds
    count = candidate_role_ids.reject(&:blank?).size
    if count < 1
      errors.add(:candidate_role_ids, "You must select at least one specialization.")
    elsif count > 5
      errors.add(:candidate_role_ids, "You can select up to 5 specializations only.")
    end
  end
end
