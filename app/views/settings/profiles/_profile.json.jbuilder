json.extract! profile, :id, :first_name, :middle_name, :last_name, :gender, :bio, :user_id, :created_at, :updated_at
json.url profile_url(profile, format: :json)
