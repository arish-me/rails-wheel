FactoryBot.define do
  factory :role_permission do
    association :role
    association :permission
    association :company
    action { :view }

    trait :edit do
      action { :edit }
    end

    trait :view do
      action { :view }
    end
  end
end
