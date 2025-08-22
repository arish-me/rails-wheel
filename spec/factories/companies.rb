FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    sequence(:subdomain) { |n| "company#{n}" }
    website { 'https://example.com' }
    status { 1 }
  end
end
