class JobBoardSyncLog < ApplicationRecord
  belongs_to :job_board_integration
  belongs_to :job, optional: true

  validates :action, presence: true, inclusion: { in: %w[sync_job test_connection integration_created integration_updated] }
  validates :status, presence: true, inclusion: { in: %w[pending success error] }
  validates :message, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_action, ->(action) { where(action: action) }
  scope :errors, -> { where(status: "error") }
  scope :successful, -> { where(status: "success") }

  # Status enums
  enum :status, {
    pending: "pending",
    success: "success",
    error: "error"
  }

  # Action enums
  enum :action, {
    sync_job: "sync_job",
    test_connection: "test_connection",
    integration_created: "integration_created",
    integration_updated: "integration_updated"
  }

  def display_action
    action.humanize
  end

  def display_status
    case status
    when "pending"
      "In Progress"
    when "success"
      "Success"
    when "error"
      "Failed"
    else
      status.humanize
    end
  end

  def status_color
    case status
    when "pending"
      "yellow"
    when "success"
      "green"
    when "error"
      "red"
    else
      "gray"
    end
  end

  def short_message
    message.truncate(100)
  end

  def duration
    return nil unless created_at && updated_at
    (updated_at - created_at).round(2)
  end

  def metadata_summary
    return nil unless metadata.present?

    case action
    when "sync_job"
      metadata["external_id"] || "No external ID"
    when "test_connection"
      metadata["provider"] || "Unknown provider"
    else
      "View details"
    end
  end
end
