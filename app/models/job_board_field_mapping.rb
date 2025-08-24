class JobBoardFieldMapping < ApplicationRecord
  # Validations
  validates :local_field, presence: true
  validates :external_field, presence: true
  validates :field_type, presence: true, inclusion: { in: %w[string integer float boolean date datetime array object] }
  validates :is_required, inclusion: { in: [ true, false ] }
  validates :local_field, uniqueness: { scope: :job_board_integration_id, message: "field mapping already exists for this local field" }
  validates :external_field, uniqueness: { scope: :job_board_integration_id, message: "field mapping already exists for this external field" }

  # Associations
  belongs_to :job_board_integration

  # Scopes
  scope :required, -> { where(is_required: true) }
  scope :optional, -> { where(is_required: false) }
  scope :by_field_type, ->(type) { where(field_type: type) }
  scope :ordered, -> { order(:local_field) }

  # Instance methods
  def display_name
    "#{local_field} → #{external_field}"
  end

  def required?
    is_required
  end

  def optional?
    !is_required
  end

  def has_default_value?
    default_value.present?
  end

  def transform_value(value)
    return default_value if value.blank? && has_default_value?
    return value if value.blank?

    case field_type
    when "integer"
      value.to_i
    when "float"
      value.to_f
    when "boolean"
      ActiveModel::Type::Boolean.new.cast(value)
    when "date"
      Date.parse(value.to_s) rescue value
    when "datetime"
      DateTime.parse(value.to_s) rescue value
    when "array"
      value.is_a?(Array) ? value : [ value ]
    when "object"
      value.is_a?(Hash) ? value : { value: value }
    else
      value.to_s
    end
  rescue StandardError => e
    Rails.logger.warn "Failed to transform field #{local_field}: #{e.message}"
    value
  end

  def transform_value_back(value)
    return value if value.blank?

    case field_type
    when "string"
      value.to_s
    when "integer"
      value.to_i
    when "float"
      value.to_f
    when "boolean"
      ActiveModel::Type::Boolean.new.cast(value)
    when "date"
      Date.parse(value.to_s) rescue value
    when "datetime"
      DateTime.parse(value.to_s) rescue value
    when "array"
      value.is_a?(Array) ? value : [ value ]
    when "object"
      value.is_a?(Hash) ? value : { value: value }
    else
      value.to_s
    end
  rescue StandardError => e
    Rails.logger.warn "Failed to transform field #{local_field} back: #{e.message}"
    value
  end

  def validate_value(value)
    return true if value.blank? && !required?

    case field_type
    when "integer"
      value.to_s.match?(/\A\d+\z/)
    when "float"
      value.to_s.match?(/\A\d+(\.\d+)?\z/)
    when "boolean"
      [ true, false, "true", "false", 1, 0, "1", "0" ].include?(value)
    when "date"
      Date.parse(value.to_s) rescue false
    when "datetime"
      DateTime.parse(value.to_s) rescue false
    when "array"
      value.is_a?(Array)
    when "object"
      value.is_a?(Hash)
    else
      true
    end
  rescue StandardError
    false
  end

  def validation_error_message(value)
    return nil if validate_value(value)

    case field_type
    when "integer"
      "must be a valid integer"
    when "float"
      "must be a valid number"
    when "boolean"
      "must be true or false"
    when "date"
      "must be a valid date"
    when "datetime"
      "must be a valid datetime"
    when "array"
      "must be an array"
    when "object"
      "must be an object/hash"
    else
      "has invalid format"
    end
  end

  # Class methods
  def self.create_mapping(integration, local_field, external_field, options = {})
    find_or_initialize_by(
      job_board_integration: integration,
      local_field: local_field
    ).tap do |mapping|
      mapping.external_field = external_field
      mapping.field_type = options[:field_type] || "string"
      mapping.is_required = options[:is_required] || false
      mapping.default_value = options[:default_value]
      mapping.save!
    end
  end

  def self.bulk_create_mappings(integration, mappings)
    mappings.each do |mapping_data|
      create_mapping(integration, mapping_data[:local_field], mapping_data[:external_field], mapping_data.except(:local_field, :external_field))
    end
  end

  def self.required_fields_for_integration(integration)
    where(job_board_integration: integration, is_required: true).pluck(:local_field)
  end

  def self.field_mappings_for_integration(integration)
    where(job_board_integration: integration).index_by(&:local_field)
  end
end
