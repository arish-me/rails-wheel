class Chapter < ApplicationRecord
  extend FriendlyId
  default_scope { order(position: :asc) }

  belongs_to :topic
  validates :name, presence: true

  friendly_id :name, use: :slugged
  acts_as_list scope: :topic # Chapters are scoped by their topic

  def display_number
    "#{topic.position}.#{position}" # e.g., "1.1", "1.2"
  end

   # Navigate to the next chapter, or go to the first chapter of the next topic
  def next_chapter_or_first_of_next_topic
    if lower_item
      lower_item
    else
      next_topic = topic.lower_item
      next_topic&.chapters&.first
    end
  end

  # Navigate to the previous chapter
  def previous_chapter_or_last_of_previous_topic
    if higher_item
      higher_item
    else
      previous_topic = topic.higher_item
      previous_topic&.chapters&.last
    end
  end

end
