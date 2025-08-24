FactoryBot.define do
  factory :job_board_field_mapping do
    job_board_integration { nil }
    local_field { "MyString" }
    external_field { "MyString" }
    field_type { "MyString" }
    is_required { false }
    default_value { "MyString" }
  end
end
