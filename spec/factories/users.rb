FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.now } # If using Devise confirmable

    # Skip callbacks by default to avoid unexpected behavior in tests
    after(:build) { |user| user.skip_password_validation = true }

    # Turns off the after_create callback that assigns the default role
    transient do
      skip_default_role { true }
    end

    after(:create) do |user, evaluator|
      user.skip_password_validation = false

      # Only create the default role if skip_default_role is false
      if !evaluator.skip_default_role
        # Let the model's callback handle it
      else
        # Skip the default role assignment callback
        user.class.skip_callback(:create, :after, :assign_default_role)
      end
    end

    trait :with_profile do
      after(:create) do |user|
        create(:profile, user: user)
      end
    end

    factory :user_with_default_role do
      transient do
        skip_default_role { false }
      end

      before(:create) do
        # Ensure a default role exists
        create(:default_role) unless Role.find_by(is_default: true)
      end
    end

    factory :admin do
      after(:create) do |user|
        admin_role = create(:admin_role)
        create(:user_role, user: user, role: admin_role)
      end
    end

    factory :super_admin do
      after(:create) do |user|
        super_admin_role = create(:super_admin_role)
        create(:user_role, user: user, role: super_admin_role)
      end
    end
  end
end
