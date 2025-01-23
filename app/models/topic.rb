class Topic < ApplicationRecord
  extend FriendlyId
  belongs_to :course
  has_many :chapters, dependent: :destroy
  has_rich_text :content
  validates :heading, presence: true
  friendly_id :heading, use: :slugged
  acts_as_list
end
