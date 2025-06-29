class Company < ApplicationRecord
 validates :name, presence: true, uniqueness: { case_sensitive: false }
 validates :subdomain, presence: true, uniqueness: { case_sensitive: false }
 after_create :assign_default_roles
 has_many :users

 pg_search_scope :search_by_name,
                against: :name,
                using: {
                  tsearch: { prefix: true }
                }


 def assign_default_roles
  ActsAsTenant.with_tenant(self) do
    SeedData::MainSeeder.new.seed_initial_data
  end
 end
end
