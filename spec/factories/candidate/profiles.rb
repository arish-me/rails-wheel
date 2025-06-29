FactoryBot.define do
  factory :candidate_profile, class: 'Candidate::Profile' do
    candidate { nil }
    experience { 1 }
    hourly_rate { "9.99" }
  end
end
