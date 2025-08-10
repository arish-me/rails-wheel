FactoryBot.define do
  factory :job_board_integration do
    company { nil }
    name { "MyString" }
    provider { "MyString" }
    api_key { "MyString" }
    api_secret { "MyString" }
    webhook_url { "MyString" }
    settings { "" }
    status { "MyString" }
    last_sync_at { "2025-08-10 13:59:02" }
  end
end
