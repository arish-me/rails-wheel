class Company < ApplicationRecord
 include Avatarable
 include Candidates::HasOnlineProfiles
 attr_accessor :redirect_to, :delete_avatar_image

 validates :name, presence: true, uniqueness: { case_sensitive: false }
 validates :subdomain, presence: true, uniqueness: { case_sensitive: false }
 validates :website, presence: true, uniqueness: { case_sensitive: false }
 after_create :assign_default_roles
 has_many :users
 has_many :user_roles, dependent: :destroy
 has_many :roles, through: :user_roles
 has_many :categories, dependent: :destroy
 has_many :jobs, dependent: :destroy
 has_many :job_applications, through: :jobs
 has_many :job_board_integrations, dependent: :destroy

 pg_search_scope :search_by_name,
                against: :name,
                using: {
                  tsearch: { prefix: true }
                }

   accepts_nested_attributes_for :users

  # Override avatar validation for Company model - require on create
  validates :avatar, attached: true, on: :create

 def assign_default_roles
  ActsAsTenant.with_tenant(self) do
    SeedData::MainSeeder.new(seed_user: false).seed_initial_data
  end
 end

   def attach_avatar(image_url)
    return if avatar.attached? # Avoid re-downloading if avatar is already attached

    begin
      uri = URI.parse(image_url)
      avatar_file = uri.open
      avatar.attach(io: avatar_file, filename: "avatar.jpg", content_type: avatar_file.content_type)
    rescue StandardError => e
      Rails.logger.error "Failed to attach avatar: #{e.message}"
    end
  end
end
