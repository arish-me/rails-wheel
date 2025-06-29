FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "Role#{n}" }
    is_default { false }
    association :company

    trait :default do
      is_default { true }
    end

    trait :without_company do
      company { nil }
    end

    trait :super_admin do
      name { "SuperAdmin" }
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

    factory :manager_role do
      name { "Manager" }
    end

    factory :editor_role do
      name { "Editor" }
    end

    factory :viewer_role do
      name { "Viewer" }
    end

    # Factory for roles with permissions
    factory :role_with_permissions do
      transient do
        permissions_count { 3 }
      end

      after(:create) do |role, evaluator|
        create_list(:role_permission, evaluator.permissions_count, role: role)
      end
    end

    # Factory for roles with users
    factory :role_with_users do
      transient do
        users_count { 2 }
      end

      after(:create) do |role, evaluator|
        create_list(:user_role, evaluator.users_count, role: role)
      end
    end
  end
end
