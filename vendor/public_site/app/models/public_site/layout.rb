module PublicSite
  class Layout < ApplicationRecord
    belongs_to :client
    #has_many :templates, dependent: :destroy # Nullify the layout reference if deleted

    validates :name, presence: true
    validates :content, presence: true
  end
end
