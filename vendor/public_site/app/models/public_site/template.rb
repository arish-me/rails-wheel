module PublicSite
  class Template < ApplicationRecord
    include PgSearch::Model
    pg_search_scope :search_by_name,
          against: :name,
          using: {
            tsearch: { prefix: true } # Enables partial matches (e.g., "Admin" matches "Administrator")
          }

    belongs_to :client
    belongs_to :layout, optional: true # Templates may or may not use a layout

    validates :name, presence: true
    #validates :content, presence: true
    # has_rich_text :html_content
    has_rich_text :css_content
  end
end
