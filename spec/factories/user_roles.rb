FactoryBot.define do
  factory :user_role do
    association :user
    association :role
    association :company
  end
end
