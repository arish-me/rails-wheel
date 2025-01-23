class Chapter < ApplicationRecord
  belongs_to :topic
  validates :name, presence: true
  acts_as_list scope: :topic # Chapters are scoped by their topic

  def display_number
    "#{topic.position}.#{position}" # e.g., "1.1", "1.2"
  end
end
