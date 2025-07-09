class Candidate::Profile < ApplicationRecord
  belongs_to :candidate
  belongs_to :candidate_role, optional: true

  has_one_attached :cover_image do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [ 400, 200 ]
    attachable.variant :medium, resize_to_limit: [ 800, 400 ]
    attachable.variant :large, resize_to_limit: [ 1200, 600 ]
  end

  has_one :user, through: :candidate
  has_one :location, as: :locatable, dependent: :destroy, autosave: true
  accepts_nested_attributes_for :user

  validates :headline, presence: true
  validates :candidate_role, presence: true

  def display_name
    user&.display_name || "Unknown"
  end

  def cover_image_url
    cover_image.attached? ? cover_image : nil
  end

  def profile_image_url
    profile_image.attached? ? profile_image : nil
  end
end
