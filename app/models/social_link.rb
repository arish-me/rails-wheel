class SocialLink < ApplicationRecord
  include Candidates::HasOnlineProfiles

  belongs_to :linkable, polymorphic: true

  validates :github, :linked_in, presence: true
end
