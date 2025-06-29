FactoryBot.define do
  factory :role_permission do
    role
    permission
    action { "view" }

    trait :edit do
      action { "edit" }
    end
  end
end
