class Site < ApplicationRecord
  belongs_to :account
  has_many :pages, dependent: :destroy
  has_many :themes, dependent: :destroy

  validates :name, :subdomain, presence: true
  validates :subdomain, uniqueness: true

  # Use a method for full URL
  def full_url
    "http://#{subdomain}.localhost:3000"
  end
end
