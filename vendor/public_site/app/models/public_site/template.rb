module PublicSite
  class Template < ApplicationRecord
    belongs_to :client
    belongs_to :layout, optional: true # Templates may or may not use a layout

    validates :name, presence: true
    validates :content, presence: true
  end
end
