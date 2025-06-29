class Category < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  pg_search_scope :search_by_name,
                against: :name,
                using: {
                  tsearch: { prefix: true }
                }
end
