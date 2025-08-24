class JobBoardSyncLog < ApplicationRecord
  # Enums
  enum :status, { success: 0, error: 1, warning: 2, info: 3 }

  # Validations
  validates :action, presence: true
  validates :status, presence: true
  validates :message, presence: true

  # Associations
  belongs_to :job_board_integration
  belongs_to :job, optional: true

  # Scopes
  scope :recent, -> { order(created_at: :desc).limit(100) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_action, ->(action) { where(action: action) }
  scope :successful, -> { where(status: :success) }
  scope :failed, -> { where(status: :error) }

  # Instance methods
  def display_action
    action.humanize
  end

  def display_status
    status.humanize
  end

  def success?
    status == "success"
  end

  def error?
    status == "error"
  end

  def warning?
    status == "warning"
  end

  def info?
    status == "info"
  end

  def metadata_summary
    return "No metadata" if metadata.blank?

    metadata.keys.join(", ")
  end

  def duration
    return nil unless metadata&.dig("duration")

    metadata["duration"]
  end

  def error_details
    return nil unless error?

    metadata&.dig("error_details") || message
  end

  def api_response
    metadata&.dig("api_response")
  end

  def request_payload
    metadata&.dig("request_payload")
  end

  def response_code
    metadata&.dig("response_code")
  end

  def response_time
    metadata&.dig("response_time")
  end

  # Class methods
  def self.log_success(integration, action, message, job: nil, metadata: {})
    create!(
      job_board_integration: integration,
      job: job,
      action: action,
      status: :success,
      message: message,
      metadata: metadata
    )
  end

  def self.log_error(integration, action, message, job: nil, metadata: {})
    create!(
      job_board_integration: integration,
      job: job,
      action: action,
      status: :error,
      message: message,
      metadata: metadata
    )
  end

  def self.log_warning(integration, action, message, job: nil, metadata: {})
    create!(
      job_board_integration: integration,
      job: job,
      action: action,
      status: :warning,
      message: message,
      metadata: metadata
    )
  end

  def self.log_info(integration, action, message, job: nil, metadata: {})
    create!(
      job_board_integration: integration,
      job: job,
      action: action,
      status: :info,
      message: message,
      metadata: metadata
    )
  end

  def self.stats_for_integration(integration)
    logs = where(job_board_integration: integration)

    {
      total: logs.count,
      success: logs.successful.count,
      error: logs.failed.count,
      warning: logs.by_status(:warning).count,
      info: logs.by_status(:info).count,
      last_24_hours: logs.where("created_at > ?", 24.hours.ago).count,
      last_7_days: logs.where("created_at > ?", 7.days.ago).count
    }
  end
end
