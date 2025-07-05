class SocialLink < ApplicationRecord
  include Candidates::HasOnlineProfiles
  belongs_to :linkable, polymorphic: true
end
