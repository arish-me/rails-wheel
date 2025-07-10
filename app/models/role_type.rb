class RoleType < ApplicationRecord
  TYPES = %i[part_time_contract full_time_contract full_time_employment].freeze

  # belongs_to :work_preference, class_name: "Candidate::WorkPreference"

  validate :at_least_one_type_selected

  def missing_fields?
    TYPES.none? { |t| send(t) }
  end

  def humanize
    TYPES.select { |t| send(t) }.map { |t| t.to_s.humanize }.to_sentence
  end

  def only_full_time_employment?
    full_time_employment &&
      !part_time_contract? &&
      !full_time_contract?
  end

  private

  def at_least_one_type_selected
    unless TYPES.any? { |t| send(t) }
      errors.add(:base, :at_least_one_type_selected)
    end
  end
end
