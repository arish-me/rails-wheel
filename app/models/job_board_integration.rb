class JobBoardIntegration < ApplicationRecord
  # Enums
  enum :status, { inactive: 0, active: 1, error: 2, testing: 3 }

  # Validations
  validates :name, presence: true
  validates :provider, presence: true
  validates :api_key, presence: true
  validates :api_secret, presence: true, if: :requires_api_secret?
  validates :webhook_url, format: { with: URI.regexp }, allow_blank: true
  validates :provider, uniqueness: { scope: :company_id, message: "integration already exists for this provider" }

  # Associations
  belongs_to :company
  belongs_to :job_board_provider, foreign_key: :provider, primary_key: :slug, optional: true
  has_many :job_board_sync_logs, dependent: :destroy
  has_many :job_board_field_mappings, dependent: :destroy
  has_many :jobs, through: :job_board_sync_logs

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :by_provider, -> { order(:provider) }
  scope :recently_synced, -> { where("last_sync_at > ?", 1.hour.ago) }

  # Callbacks
  before_validation :set_default_settings
  after_create :create_default_field_mappings
  after_update :log_status_change, if: :saved_change_to_status?

  # Instance methods
  def provider_info
    job_board_provider
  end

  def field_mapping_for(local_field)
    job_board_field_mappings.find_by(local_field: local_field)
  end

  def display_name
    "#{name} (#{provider_info&.name || provider})"
  end

  def active?
    status == "active"
  end

  def can_sync?
    active? && api_key.present?
  end

  def requires_api_secret?
    provider_info&.auth_type == "oauth" || provider_info&.auth_type == "basic_auth"
  end

  def auto_sync_enabled?
    settings&.dig("auto_sync") == true
  end

  def sync_interval
    settings&.dig("sync_interval") || 3600 # Default to 1 hour
  end

  def post_new_jobs?
    settings&.dig("post_new_jobs") == true
  end

  def update_existing_jobs?
    settings&.dig("update_existing_jobs") == true
  end

  def delete_closed_jobs?
    settings&.dig("delete_closed_jobs") == true
  end

  def field_mapping_for(local_field)
    job_board_field_mappings.find_by(local_field: local_field)
  end

  def map_field(local_field, external_field, field_type: "string", is_required: false, default_value: nil)
    job_board_field_mappings.find_or_initialize_by(local_field: local_field).tap do |mapping|
      mapping.external_field = external_field
      mapping.field_type = field_type
      mapping.is_required = is_required
      mapping.default_value = default_value
      mapping.save!
    end
  end

  def push_job_to_external(job)
    return unless can_sync?

    JobBoardSyncService.new(self).push_job_to_external(job)
  end

  def test_connection
    JobBoardSyncService.new(self).test_connection
  end

  def sync_all_jobs
    return unless can_sync?

    JobBoardSyncService.new(self).sync_all_jobs
  end

  def log_sync(action, status, message, job: nil, metadata: {})
    job_board_sync_logs.create!(
      job: job,
      action: action,
      status: status,
      message: message,
      metadata: metadata
    )
  end

  def last_sync_status
    job_board_sync_logs.order(:created_at).last&.status
  end

  def sync_stats
    {
      total_syncs: job_board_sync_logs.count,
      successful_syncs: job_board_sync_logs.where(status: "success").count,
      failed_syncs: job_board_sync_logs.where(status: "error").count,
      last_sync: last_sync_at
    }
  end

  private

  def set_default_settings
    self.settings ||= {
      auto_sync: false,
      sync_interval: 3600,
      post_new_jobs: true,
      update_existing_jobs: true,
      delete_closed_jobs: false,
      custom_fields: {}
    }
  end

  def create_default_field_mappings
    return unless provider_info

    default_mappings = {
      "title" => "title",
      "description" => "description",
      "location" => "location",
      "salary_min" => "salary_min",
      "salary_max" => "salary_max",
      "salary_currency" => "salary_currency",
      "job_type" => "job_type",
      "experience_level" => "experience_level",
      "remote_work" => "remote_work",
      "company_name" => "company_name"
    }

    default_mappings.each do |local_field, external_field|
      job_board_field_mappings.create!(
        local_field: local_field,
        external_field: external_field,
        field_type: "string",
        is_required: local_field.in?(%w[title description])
      )
    end
  end

  def log_status_change
    log_sync(
      "status_changed",
      "info",
      "Integration status changed from #{status_previous_change.first} to #{status}",
      metadata: { previous_status: status_previous_change.first, new_status: status }
    )
  end
end
