class Course < ApplicationRecord
  extend FriendlyId
  has_many :topics, dependent: :destroy
  has_many :chapters, through: :topics, dependent: :destroy
  validates :name, presence: true
  friendly_id :custom_slug, use: :slugged
  has_one_attached :avatar do |attachable|
    attachable.variant :thumbnail, resize_to_fill: [ 300, 300 ]
  end


  pg_search_scope :search_by_name,
              against: :name,
              using: {
                tsearch: { prefix: true } # Enables partial matches (e.g., "Admin" matches "Administrator")
              }
end
