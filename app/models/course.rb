class Course < ApplicationRecord
  has_many :technologies, dependent: :destroy
  validates :name, presence: true

  pg_search_scope :search_by_name,
              against: :name,
              using: {
                tsearch: { prefix: true } # Enables partial matches (e.g., "Admin" matches "Administrator")
              }
end
