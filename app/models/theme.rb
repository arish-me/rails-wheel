class Theme < ApplicationRecord
  include ActiveModel::Serialization
  belongs_to :site

  validates :name, presence: true
end
