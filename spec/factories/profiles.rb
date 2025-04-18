FactoryBot.define do
  factory :profile do
    user
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    gender { Profile.genders.keys.sample }
    bio { Faker::Lorem.paragraph(sentence_count: 2) }
    phone_number { Faker::PhoneNumber.phone_number }
    date_of_birth { 30.years.ago }
    location { "#{Faker::Address.city}, #{Faker::Address.country}" }
    website { Faker::Internet.url }
  end
end
