FactoryBot.define do
  factory :job_board_integration do
    company { nil }
    name { "MyString" }
    provider { "MyString" }
    api_key { "MyString" }
    api_secret { "MyString" }
    webhook_url { "MyString" }
    status { 1 }
    settings { "" }
    last_sync_at { "2025-08-23 16:08:30" }
  end
end
