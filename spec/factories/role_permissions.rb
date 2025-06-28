FactoryBot.define do
  factory :role_permission do
    association :role
    association :permission
    action { 0 } # 0 for read, 1 for write, etc.
    association :company

    trait :edit do
      action { 1 }
    end
  end
end
