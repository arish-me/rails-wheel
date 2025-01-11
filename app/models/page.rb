class Page < ApplicationRecord
  belongs_to :site

  validates :title, :slug, presence: true
  validates :slug, uniqueness: { scope: :site_id }

  # Render dynamic content using Liquid templates
  def render_content(assigns = {})
    Liquid::Template.parse(content).render(assigns)
  end
end
