class JobBoardIntegration < ApplicationRecord
  belongs_to :company
  belongs_to :job_board_provider, foreign_key: "provider", primary_key: "slug"
  has_many :job_board_sync_logs, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :provider, presence: true, inclusion: { in: JobBoardProvider::PROVIDERS.keys }
  validates :api_key, presence: true, length: { minimum: 10 }
  validates :api_secret, presence: true, length: { minimum: 10 }
  validates :status, presence: true, inclusion: { in: %w[active inactive error] }
  validates :webhook_url, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true

  scope :active, -> { where(status: "active") }
  scope :by_provider, ->(provider) { where(provider: provider) }
  scope :ordered, -> { order(:name) }

  # Status enums
  enum :status, {
    active: "active",
    inactive: "inactive",
    error: "error"
  }

  # Settings schema
  SETTINGS_SCHEMA = {
    auto_sync: { type: :boolean, default: true },
    sync_interval: { type: :integer, default: 3600 }, # in seconds
    post_new_jobs: { type: :boolean, default: true },
    update_existing_jobs: { type: :boolean, default: true },
    delete_closed_jobs: { type: :boolean, default: false },
    custom_fields: { type: :hash, default: {} }
  }.freeze

  before_validation :set_defaults
  after_create :log_integration_created
  after_update :log_integration_updated

  def display_name
    "#{name} (#{job_board_provider&.name || provider})"
  end

  def active?
    status == "active"
  end

  def can_sync?
    active? && api_key.present? && api_secret.present?
  end

  def last_sync_status
    last_log = job_board_sync_logs.order(created_at: :desc).first
    last_log&.status || "never"
  end

  def sync_job(job)
    return false unless can_sync?

    log = job_board_sync_logs.create!(
      job: job,
      action: "sync_job",
      status: "pending",
      message: "Syncing job '#{job.title}' to #{provider}"
    )

    begin
      # Here you would implement the actual API call to the job board
      # For now, we'll simulate a successful sync
      result = simulate_job_sync(job)

      log.update!(
        status: result[:success] ? "success" : "error",
        message: result[:message],
        metadata: result[:metadata]
      )

      update!(last_sync_at: Time.current) if result[:success]

      result[:success]
    rescue StandardError => e
      log.update!(
        status: "error",
        message: "Sync failed: #{e.message}",
        metadata: { error: e.class.name, backtrace: e.backtrace.first(5) }
      )
      false
    end
  end

  def test_connection
    return false unless can_sync?

    log = job_board_sync_logs.create!(
      action: "test_connection",
      status: "pending",
      message: "Testing connection to #{provider}"
    )

    begin
      # Here you would implement the actual API test
      # For now, we'll simulate a successful test
      result = simulate_connection_test

      log.update!(
        status: result[:success] ? "success" : "error",
        message: result[:message],
        metadata: result[:metadata]
      )

      result[:success]
    rescue StandardError => e
      log.update!(
        status: "error",
        message: "Connection test failed: #{e.message}",
        metadata: { error: e.class.name, backtrace: e.backtrace.first(5) }
      )
      false
    end
  end

  private

  def set_defaults
    self.status ||= "inactive"
    self.settings ||= {}
  end

  def log_integration_created
    job_board_sync_logs.create!(
      action: "integration_created",
      status: "success",
      message: "Integration '#{name}' created for #{provider}"
    )
  end

  def log_integration_updated
    job_board_sync_logs.create!(
      action: "integration_updated",
      status: "success",
      message: "Integration '#{name}' updated"
    )
  end

  def simulate_job_sync(job)
    # Simulate API call delay
    sleep(0.5)

    # Simulate success/failure based on job status
    if job.published?
      {
        success: true,
        message: "Job '#{job.title}' successfully synced to #{provider}",
        metadata: { external_id: "ext_#{job.id}_#{Time.current.to_i}" }
      }
    else
      {
        success: false,
        message: "Cannot sync job '#{job.title}' - job is not published",
        metadata: { job_status: job.status }
      }
    end
  end

  def simulate_connection_test
    # Simulate API test delay
    sleep(0.3)

    # Simulate success/failure based on API credentials
    if api_key.length >= 20 && api_secret.length >= 20
      {
        success: true,
        message: "Successfully connected to #{provider}",
        metadata: { provider: provider, timestamp: Time.current }
      }
    else
      {
        success: false,
        message: "Invalid API credentials for #{provider}",
        metadata: { provider: provider, error: "invalid_credentials" }
      }
    end
  end
end
