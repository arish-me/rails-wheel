FactoryBot.define do
  factory :job_board_sync_log do
    job_board_integration { nil }
    job { nil }
    action { 'MyString' }
    status { 'MyString' }
    message { 'MyText' }
    metadata { '' }
  end
end
