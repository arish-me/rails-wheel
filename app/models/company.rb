class Company < ApplicationRecord
 attr_accessor :redirect_to

 validates :name, presence: true, uniqueness: { case_sensitive: false }
 validates :subdomain, presence: true, uniqueness: { case_sensitive: false }
 after_create :assign_default_roles
 has_many :users

  has_one_attached :avatar do |attachable|
      attachable.variant :thumbnail, resize_to_fill: [ 300, 300 ], convert: :webp, saver: { quality: 80 }
      attachable.variant :small, resize_to_fill: [ 72, 72 ], convert: :webp, saver: { quality: 80 }, preprocessed: true
  end

 pg_search_scope :search_by_name,
                against: :name,
                using: {
                  tsearch: { prefix: true }
                }

 accepts_nested_attributes_for :users
 def assign_default_roles
  ActsAsTenant.with_tenant(self) do
    SeedData::MainSeeder.new.seed_initial_data
  end
 end
end
