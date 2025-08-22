FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    confirmed_at { Time.current }
    user_type { :user }
    gender { :he_she }
    theme { :system }
    country_code { 'US' }
    date_format { '%d.%m.%Y' }
    locale { 'en' }
    active { true }
    bio { Faker::Lorem.paragraph(sentence_count: 3) }
    phone_number { Faker::PhoneNumber.phone_number }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    location { Faker::Address.city }
    website { Faker::Internet.url }
    social_links { { twitter: Faker::Internet.username, linkedin: Faker::Internet.username } }
    goals { ['Learn Rails', 'Build great apps'] }

    # Skip password validation by default for faster tests
    after(:build) { |user| user.skip_password_validation = true }

    # Skip default role assignment by default
    transient do
      skip_default_role { true }
    end

    # Trait for users with profile image
    trait :with_profile_image do
      after(:build) do |user|
        user.profile_image.attach(
          io: Rails.root.join('spec/fixtures/files/avatar.png').open,
          filename: 'avatar.jpg',
          content_type: 'image/jpeg'
        )
      end
    end

    # Trait for confirmed users
    trait :confirmed do
      confirmed_at { Time.current }
    end

    # Trait for unconfirmed users
    trait :unconfirmed do
      confirmed_at { nil }
      confirmation_sent_at { Time.current }
    end

    # Trait for locked users
    trait :locked do
      locked_at { Time.current }
      failed_attempts { 5 }
    end

    # Trait for onboarded users
    trait :onboarded do
      onboarded_at { Time.current }
      set_onboarding_preferences_at { Time.current }
      set_onboarding_goals_at { Time.current }
    end

    # Trait for users with company
    trait :with_company do
      association :company
    end

    # Trait for platform admins
    trait :platform_admin do
      user_type { :platform_admin }
    end

    # Trait for company users
    trait :company_user do
      user_type { :company }
    end

    # Factory for users with default role
    factory :user_with_default_role do
      transient do
        skip_default_role { false }
      end

      after(:create) do |user, evaluator|
        unless evaluator.skip_default_role
          default_role = Role.find_by(is_default: true) || create(:default_role)
          create(:user_role, user: user, role: default_role)
        end
      end
    end

    # Factory for admin users
    factory :admin do
      after(:create) do |user|
        admin_role = create(:admin_role)
        create(:user_role, user: user, role: admin_role)
      end
    end

    # Factory for super admin users
    factory :super_admin do
      after(:create) do |user|
        super_admin_role = create(:super_admin_role)
        create(:user_role, user: user, role: super_admin_role)
      end
    end

    # Factory for complete user profile
    factory :complete_user do
      after(:create) do |user|
        default_role = Role.find_by(is_default: true) || create(:default_role)
        create(:user_role, user: user, role: default_role)
      end
    end
  end
end
