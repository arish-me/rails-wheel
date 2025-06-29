FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    association :user
  end
end
