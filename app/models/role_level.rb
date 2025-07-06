class RoleLevel < ApplicationRecord
  TYPES = %i[junior mid senior principal c_level].freeze

  belongs_to :candidate

  def missing_fields?
    TYPES.none? { |t| send(t) }
  end
end
