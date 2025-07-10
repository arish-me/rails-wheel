class Candidate < ApplicationRecord
  include Hashid::Rails

  attr_accessor :redirect_to

  belongs_to :user
  # belongs_to :candidate_role, optional: true
  # has_one :profile, class_name: "Candidate::Profile", dependent: :destroy
  # has_one :work_preference, class_name: "Candidate::WorkPreference", dependent: :destroy
  has_one :role_type, class_name: "RoleType", dependent: :destroy
  has_one :role_level, class_name: "RoleLevel", dependent: :destroy

  has_one :social_link, as: :linkable, dependent: :destroy
  has_one :location, as: :locatable, dependent: :destroy, autosave: true
  accepts_nested_attributes_for :user
  # accepts_nested_attributes_for :work_preference
  has_many :specializations, as: :specializable, dependent: :destroy
  has_many :candidate_roles, through: :specializations
  accepts_nested_attributes_for :specializations, allow_destroy: true
  accepts_nested_attributes_for :role_level, update_only: true
  accepts_nested_attributes_for :role_type, update_only: true

  validate :specialization_count_within_bounds, on: :update, if: :validate_for_redirect_target?

  validates :headline, presence: true, on: :update, unless: :validate_for_redirect_target?
  validates :experience, presence: true, on: :update, unless: :validate_for_redirect_target?
  validates :search_status, presence: true, on: :update, unless: :validate_for_redirect_target?
  validates :hourly_rate, presence: true, on: :update, unless: :validate_for_redirect_target?

 enum :experience, { # Renamed to experience_level to avoid conflict if you later add an integer 'experience' column
    fresher: 0,
    year_1: 1,
    year_2: 2,
    year_3: 3,
    year_4: 4,
    year_5: 5,
    year_6: 6,
    year_7: 7,
    year_8: 8,
    year_9: 9,
    year_10: 10,
    greater_than_10_years: 11 # Or use a higher number if you anticipate more granular options later
  }, default: :fresher

  enum :search_status, {
    actively_looking: 1,
    open: 2,
    not_interested: 3,
    invisible: 4
  }

   def self.experience_options_for_select
    experiences.keys.map do |key|
      case key.to_sym
      when :fresher
        ["Fresher", key]
      when :greater_than_10_years
        ["> 10 Years", key]
      when -> (k) { k.to_s.start_with?('year_') }
        # Extract the number from 'year_X' and append 'Year(s)'
        year_number = key.to_s.gsub('year_', '').to_i
        ["#{year_number} Year#{'s' if year_number > 1}", key]
      else
        [key.humanize, key] # Fallback for any other unexpected keys
      end
    end
  end

  # You might also want a display method on the instance for view rendering
  def display_experience_level
    case experience.to_sym
    when :fresher
      "Fresher"
    when :greater_than_10_years
      "> 10 Years"
    when -> (k) { k.to_s.start_with?('year_') }
      year_number = experience_level.to_s.gsub('year_', '').to_i
      "#{year_number} Year#{'s' if year_number > 1}"
    else
      experience_level.humanize # Fallback
    end
  end

  def role_level
    super || build_role_level
  end

  def role_type
    super || build_role_type
  end

   def validate_for_redirect_target?
    ['onboarding_candidate'].include?(redirect_to)
  end


  def specialization_count_within_bounds
    count = candidate_role_ids.reject(&:blank?).size
    if count < 1
      errors.add(:candidate_role_ids, "You must select at least one specialization.")
    elsif count > 5
      errors.add(:candidate_role_ids, "You can select up to 5 specializations only.")
    end
  end
end
