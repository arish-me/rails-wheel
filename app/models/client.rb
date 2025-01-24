class Client < ApplicationRecord
  pg_search_scope :search_by_name,
            against: :name,
            using: {
              tsearch: { prefix: true } # Enables partial matches (e.g., "Admin" matches "Administrator")
            }
  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/, message: "must be lowercase and contain only letters, numbers, and hyphens" }

  before_validation :generate_subdomain, on: :create

  has_many :templates, dependent: :destroy, class_name: 'PublicSite::Template'
  has_many :layouts, dependent: :destroy, class_name: 'PublicSite::Layout'

  private

  def generate_subdomain
    self.subdomain ||= name.parameterize
  end
end
