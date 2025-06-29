FactoryBot.define do
  factory :permission do
    sequence(:name) { |n| "Permission#{n}" }
    resource { "resource" }

    factory :view_permission do
      name { "view" }
    end

    factory :edit_permission do
      name { "edit" }
    end

    factory :create_permission do
      name { "create" }
    end

    factory :delete_permission do
      name { "delete" }
    end
  end
end
