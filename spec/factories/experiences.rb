FactoryBot.define do
  factory :experience do
    candidate { nil }
    company_name { "MyString" }
    job_title { "MyString" }
    start_date { "2025-07-18" }
    current_job { false }
    description { "MyText" }
  end
end
