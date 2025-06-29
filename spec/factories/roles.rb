FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "Role#{n}" }
    is_default { false }

    trait :default do
      is_default { true }
    end

    factory :default_role do
      name { "User" }
      is_default { true }
    end

    factory :admin_role do
      name { "Admin" }
    end

    factory :super_admin_role do
      name { "SuperAdmin" }
    end
  end
end
