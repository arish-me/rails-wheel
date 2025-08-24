class JobBoardProvider < ApplicationRecord
  # Enums
  enum :status, { inactive: 0, active: 1 }
  enum :auth_type, { api_key: 0, oauth: 1, basic_auth: 2, public_api: 3 }

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[a-z0-9_-]+\z/ }
  validates :base_url, presence: true, format: { with: URI.regexp }
  validates :api_documentation_url, format: { with: URI.regexp }, allow_blank: true

  # Associations
  has_many :job_board_integrations, foreign_key: :provider, primary_key: :slug, dependent: :destroy
  has_many :companies, through: :job_board_integrations

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :by_name, -> { order(:name) }

  # Callbacks
  before_validation :generate_slug, if: :name_changed?

  # Class methods
  def supported_fields
    if adapter_exists?
      adapter_class.new(nil).supported_fields
    else
      settings["supported_fields"] || []
    end
  end

  def adapter_exists?
    JobBoardAdapters::AdapterFactory.adapter_exists?(slug)
  end

  def adapter_class
    JobBoardAdapters::AdapterFactory::ADAPTERS[slug]
  end

  def self.seed_providers
    providers_data = [
      # {
      #   name: "Adzuna",
      #   description: "Job board aggregator with comprehensive job listings",
      #   api_documentation_url: "https://developer.adzuna.com/",
      #   auth_type: "api_key",
      #   base_url: "https://api.adzuna.com/v1/api",
      #   settings: {
      #     supported_fields: %w[title description location salary company_name job_type],
      #     rate_limit: 1000,
      #     rate_limit_period: "hour"
      #   }
      # },
      {
        name: "Remotive",
        description: "Remote job board with public API",
        api_documentation_url: "https://remotive.com/api-documentation",
        auth_type: "none", # Public API, no authentication required
        base_url: "https://remotive.com/api/remote-jobs",
        settings: {
          supported_fields: %w[title description location salary company_name job_type category tags],
          rate_limit: 4, # Max 4 requests per day as per their terms
          rate_limit_period: "day",
          features: ["remote_jobs", "public_api", "no_auth"]
        }
      },
      # {
      #   name: "Arbeitnow",
      #   description: "API for Job board aggregator in Europe / Remote",
      #   api_documentation_url: "https://arbeitnow.com/api",
      #   auth_type: "api_key",
      #   base_url: "https://api.arbeitnow.com",
      #   settings: {
      #     supported_fields: %w[title description location salary company_name job_type],
      #     rate_limit: 500,
      #     rate_limit_period: "hour"
      #   }
      # },
      # {
      #   name: "Careerjet",
      #   description: "Job search engine with global coverage",
      #   api_documentation_url: "https://www.careerjet.com/partners/",
      #   auth_type: "api_key",
      #   base_url: "https://api.careerjet.com",
      #   settings: {
      #     supported_fields: %w[title description location salary company_name job_type],
      #     rate_limit: 200,
      #     rate_limit_period: "hour"
      #   }
      # },
      # {
      #   name: "Findwork",
      #   description: "Job board focused on remote work opportunities",
      #   api_documentation_url: "https://findwork.dev/api",
      #   auth_type: "api_key",
      #   base_url: "https://api.findwork.dev",
      #   settings: {
      #     supported_fields: %w[title description location salary company_name job_type],
      #     rate_limit: 300,
      #     rate_limit_period: "hour"
      #   }
      # },
      # {
      #   name: "GraphQL Jobs",
      #   description: "Jobs with GraphQL API",
      #   api_documentation_url: "https://graphql.jobs/docs",
      #   auth_type: "api_key",
      #   base_url: "https://api.graphql.jobs",
      #   settings: {
      #     supported_fields: %w[title description location salary company_name job_type],
      #     rate_limit: 1000,
      #     rate_limit_period: "hour"
      #   }
      # },
      # {
      #   name: "Jooble",
      #   description: "Job search engine with global reach",
      #   api_documentation_url: "https://jooble.org/api",
      #   auth_type: "api_key",
      #   base_url: "https://api.jooble.org",
      #   settings: {
      #     supported_fields: %w[title description location salary company_name job_type],
      #     rate_limit: 500,
      #     rate_limit_period: "hour"
      #   }
      # },
      # {
      #   name: "Reed",
      #   description: "Job board aggregator for UK market",
      #   api_documentation_url: "https://www.reed.co.uk/developers/",
      #   auth_type: "api_key",
      #   base_url: "https://www.reed.co.uk/api/1.0",
      #   settings: {
      #     supported_fields: %w[title description location salary company_name job_type],
      #     rate_limit: 100,
      #     rate_limit_period: "hour"
      #   }
      # },
      # {
      #   name: "The Muse",
      #   description: "Job board and company profiles",
      #   api_documentation_url: "https://www.themuse.com/developers",
      #   auth_type: "api_key",
      #   base_url: "https://api.themuse.com",
      #   settings: {
      #     supported_fields: %w[title description location salary company_name job_type],
      #     rate_limit: 200,
      #     rate_limit_period: "hour"
      #   }
      # },
      # {
      #   name: "USAJOBS",
      #   description: "US government job board",
      #   api_documentation_url: "https://developer.usajobs.gov/",
      #   auth_type: "api_key",
      #   base_url: "https://data.usajobs.gov/api",
      #   settings: {
      #     supported_fields: %w[title description location salary company_name job_type],
      #     rate_limit: 1000,
      #     rate_limit_period: "hour"
      #   }
      # },
      # {
      #   name: "ZipRecruiter",
      #   description: "Job search app and website",
      #   api_documentation_url: "https://www.ziprecruiter.com/publishers",
      #   auth_type: "api_key",
      #   base_url: "https://api.ziprecruiter.com",
      #   settings: {
      #     supported_fields: %w[title description location salary company_name job_type],
      #     rate_limit: 500,
      #     rate_limit_period: "hour"
      #   }
      # }
    ]

    providers_data.each do |provider_data|
      find_or_create_by!(slug: provider_data[:name].downcase.gsub(/\s+/, "_")) do |provider|
        provider.assign_attributes(provider_data.except(:name))
        provider.name = provider_data[:name]
        provider.status = :active
      end
    end
  end

  # Instance methods
  def display_name
    name
  end

  def api_endpoint
    base_url
  end

  def supported_fields
    settings&.dig("supported_fields") || []
  end

  def rate_limit
    settings&.dig("rate_limit") || 100
  end

  def rate_limit_period
    settings&.dig("rate_limit_period") || "hour"
  end

  def active?
    status == "active"
  end

  private

  def generate_slug
    return if slug.present?

    self.slug = name&.downcase&.gsub(/\s+/, "_")&.gsub(/[^a-z0-9_-]/, "")
  end
end
