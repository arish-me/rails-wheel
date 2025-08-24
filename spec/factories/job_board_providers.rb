FactoryBot.define do
  factory :job_board_provider do
    name { "MyString" }
    slug { "MyString" }
    description { "MyText" }
    api_documentation_url { "MyString" }
    auth_type { "MyString" }
    base_url { "MyString" }
    status { 1 }
    settings { "" }
  end
end
