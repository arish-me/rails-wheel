# Roles
account = Account.create(name: 'Rails Wheel', subdomain: 'wheel')
ActsAsTenant.current_tenant = account

puts "Creating Roles..."
roles = %w[SuperAdmin Admin User Recruiter Guest]
default_role_name = 'User'
roles.each do |role_name|
  role = Role.find_or_create_by!(name: role_name, account_id: account.id)
  if role_name == default_role_name
    role.update!(is_default: true)
  end
end
puts "Roles created: #{roles.join(', ')}"

# Ensure only one role is marked as default
Role.where.not(name: default_role_name).update_all(is_default: false)
puts "Default role set to: #{default_role_name}"

# Permissions
puts "Creating Permissions..."
permissions = [
  { name: 'Users', resource: 'User' },
  { name: 'Roles', resource: 'Role' },
  { name: 'RolePermissions', resource: 'RolePermission' },
  { name: 'Permissions', resource: 'Permission' },
  { name: 'Categories', resource: 'Category' }
]

permissions.each do |perm|
  Permission.find_or_create_by!(name: perm[:name], resource: perm[:resource], account_id: account.id)
end
puts "Permissions created: #{permissions.map { |p| p[:name] }.join(', ')}"

# Assign All Permissions to Admin Role
puts "Assigning All Permissions to Admin Role..."
admin_role = Role.find_by(name: 'Admin')

permissions.each do |perm|
  permission = Permission.find_by(name: perm[:name], resource: perm[:resource], account_id: account.id)
  RolePermission.find_or_create_by!(
    role: admin_role,
    permission: permission,
    account_id: account.id,
    action: RolePermission.actions[:edit]
  )
end
puts "Admin now has all permissions with edit access."

puts "Assigning All Permissions to Service Role..."
role = Role.find_by(name: 'SuperAdmin')

permissions.each do |perm|
  permission = Permission.find_by(name: perm[:name], resource: perm[:resource])
  RolePermission.find_or_create_by!(
    role: role,
    permission: permission,
    account_id: account.id,
    action: RolePermission.actions[:edit]
  )
end
puts "SuperAdmin now has all permissions with edit access."

# Create Users and Assign Roles
puts "Creating Users and Assigning Roles..."
users = [
  { email: 'superadmin@wheel.com', role: 'SuperAdmin', first_name: 'Super', last_name: 'Admin', gender: 1 },
  { email: 'admin@wheel.com', role: 'Admin', first_name: 'Admin', last_name: 'User', gender: 1 },
  { email: 'user@wheel.com', role: 'User', first_name: 'Regular', last_name: 'User', gender: 1 },
  { email: 'recruiter@wheel.com', role: 'Recruiter', first_name: 'Recruiter', last_name: 'User', gender: 1 },
  { email: 'guest@wheel.com', role: 'Guest', first_name: 'Guest', last_name: 'User', gender: 1 }
]
users.each do |user_data|
  user = User.find_or_create_by!(email: user_data[:email]) do |u|
    u.password = "#{user_data[:email]}"
    u.password_confirmation = "#{user_data[:email]}"
    u.account_id = account.id
  end


  role = Role.find_by(name: user_data[:role])
  puts "Creating User Roles..."

  UserRole.find_or_create_by!(user: user, role: role, account_id: account.id)

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
