class JobBoardProvider < ApplicationRecord
  has_many :job_board_integrations, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :api_documentation_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }

  scope :active, -> { where(is_active: true) }
  scope :ordered, -> { order(:name) }

  # Available providers
  PROVIDERS = {
    "linkedin" => {
      name: "LinkedIn Jobs",
      slug: "linkedin",
      description: "Post jobs to LinkedIn Jobs platform",
      api_documentation_url: "https://developer.linkedin.com/docs/jobs-api",
      logo_url: "/images/providers/linkedin.png"
    },
    "indeed" => {
      name: "Indeed",
      slug: "indeed",
      description: "Post jobs to Indeed job board",
      api_documentation_url: "https://developer.indeed.com/docs/indeed-api/",
      logo_url: "/images/providers/indeed.png"
    },
    "glassdoor" => {
      name: "Glassdoor",
      slug: "glassdoor",
      description: "Post jobs to Glassdoor platform",
      api_documentation_url: "https://developer.glassdoor.com/api/docs/",
      logo_url: "/images/providers/glassdoor.png"
    },
    "ziprecruiter" => {
      name: "ZipRecruiter",
      slug: "ziprecruiter",
      description: "Post jobs to ZipRecruiter platform",
      api_documentation_url: "https://www.ziprecruiter.com/publishers/api",
      logo_url: "/images/providers/ziprecruiter.png"
    }
  }.freeze

  def self.seed_providers
    PROVIDERS.each do |key, provider_data|
      find_or_create_by(slug: key) do |provider|
        provider.name = provider_data[:name]
        provider.description = provider_data[:description]
        provider.api_documentation_url = provider_data[:api_documentation_url]
        provider.logo_url = provider_data[:logo_url]
        provider.is_active = true
      end
    end
  end

  def display_name
    name
  end

  def logo_path
    logo_url.presence || "/images/providers/#{slug}.png"
  end
end
