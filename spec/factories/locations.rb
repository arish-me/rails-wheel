FactoryBot.define do
  factory :location do
    locatable { nil }
    city { "MyString" }
    state { "MyString" }
    country { "MyString" }
    country_code { "MyString" }
    latitude { "MyString" }
    longitude { "MyString" }
    time_zone { "MyString" }
    utc_offset { 1 }
    data { "" }
  end
end
