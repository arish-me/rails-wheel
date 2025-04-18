class Category < ApplicationRecord
  belongs_to :user

  pg_search_scope :search_by_name,
                against: :name,
                using: {
                  tsearch: { prefix: true }
                }
end
