class Topic < ApplicationRecord
  belongs_to :course
  has_many :chapters, dependent: :destroy
  has_rich_text :content

  validates :heading, presence: true
  acts_as_list
end
