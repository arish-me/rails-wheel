class Topic < ApplicationRecord
  belongs_to :technology
  has_rich_text :content

  validates :heading, presence: true
end
