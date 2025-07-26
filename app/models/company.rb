class Company < ApplicationRecord
 attr_accessor :redirect_to

 validates :name, presence: true, uniqueness: { case_sensitive: false }
 validates :subdomain, presence: true, uniqueness: { case_sensitive: false }
 after_create :assign_default_roles
 has_many :users

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
