FactoryBot.define do
  factory :job_board_provider do
    name { "MyString" }
    slug { "MyString" }
    description { "MyText" }
    api_documentation_url { "MyString" }
    logo_url { "MyString" }
    is_active { false }
  end
end
