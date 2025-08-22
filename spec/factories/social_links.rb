FactoryBot.define do
  factory :social_link do
    linkable { nil }
    github { 'MyString' }
    linked_in { 'MyString' }
    website { 'MyString' }
    twitter { 'MyString' }
  end
end
