class Company < ApplicationRecord
 validates :name, presence: true, uniqueness: { case_sensitive: false }
 validates :subdomain, presence: true, uniqueness: { case_sensitive: false }
end
