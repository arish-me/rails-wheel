# db/seeds/service_account_seeds.rb

puts 'Seeding Service Account...'

account = Account.create(name: 'Service', subdomain: 'services')

ActsAsTenant.current_tenant = account

puts "Creating Roles..."
roles = %w[Service User]
default_role_name = 'User'

roles.each do |role_name|
  role = Role.find_or_create_by!(name: role_name)
  # Set the default role
  if role_name == default_role_name
    role.update!(is_default: true)
  end
end
puts "Roles created: #{roles.join(', ')}"

users = [
  { email: 'serviceuser@service.com', role: 'Service', first_name: 'Service', last_name: 'User', gender: 1 },
]

users.each do |user_data|
  user = User.find_or_create_by!(email: user_data[:email]) do |u|
    u.password = "#{user_data[:email]}"
    u.password_confirmation = "#{user_data[:email]}"
    u.account_id = account.id
  end

  role = Role.find_by(name: user_data[:role])
  UserRole.find_or_create_by!(user: user, role: role)

  profile = user.profile || user.build_profile
  profile.assign_attributes(
    first_name: user_data[:first_name],
    last_name: user_data[:last_name],
    gender: user_data[:gender]
  )
  profile.save!
end

puts "Users created and assigned roles."
puts "Seeding completed successfully!"