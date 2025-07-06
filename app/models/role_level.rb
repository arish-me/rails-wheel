class RoleLevel < ApplicationRecord
  TYPES = %i[junior mid senior principal c_level].freeze

  belongs_to :candidate

  validate :at_least_one_level_selected

  def missing_fields?
    TYPES.none? { |t| send(t) }
  end

  private

  def at_least_one_level_selected
    unless TYPES.any? { |t| send(t) }
      errors.add(:base, :at_least_one_level_selected)
    end
  end
end
