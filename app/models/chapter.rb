class Chapter < ApplicationRecord
  belongs_to :topic
  validates :name, presence: true
end
