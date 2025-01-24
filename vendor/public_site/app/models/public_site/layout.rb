module PublicSite
  class Layout < ApplicationRecord
    include PgSearch::Model
    pg_search_scope :search_by_name,
          against: :name,
          using: {
            tsearch: { prefix: true } # Enables partial matches (e.g., "Admin" matches "Administrator")
          }

    belongs_to :client
    has_many :templates, dependent: :nullify

    validates :name, presence: true
    validates :content, presence: true
  end
end
