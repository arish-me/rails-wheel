# Roles
puts "Creating Roles..."
roles = %w[SuperAdmin Admin User Recruiter Guest]
default_role_name = 'User' # Specify which role should be the default

roles.each do |role_name|
  role = Role.find_or_create_by!(name: role_name)
  # Set the default role
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
  Permission.find_or_create_by!(name: perm[:name], resource: perm[:resource])
end
puts "Permissions created: #{permissions.map { |p| p[:name] }.join(', ')}"

# SuperAdmin Role and Assign Permissions
puts "Assigning All Permissions to SuperAdmin Role..."
super_admin_role = Role.find_by(name: 'SuperAdmin')

permissions.each do |perm|
  permission = Permission.find_by(name: perm[:name], resource: perm[:resource])
  RolePermission.find_or_create_by!(
    role: super_admin_role,
    permission: permission,
    action: RolePermission.actions[:edit]
  )
end
puts "SuperAdmin now has all permissions with edit access."

# Create Users and Assign Roles
puts "Creating Users and Assigning Roles..."
super_admin_user = User.find_or_create_by!(email: 'superadmin@wheel.com') do |user|
  user.password = 'superadmin@example.com'
  user.password_confirmation = 'superadmin@example.com'
end

admin_user = User.find_or_create_by!(email: 'thermic.arish@gmail.com') do |user|
  user.password = 'thermic.arish@gmail.com'
  user.password_confirmation = 'thermic.arish@gmail.com'
end

# Assign Roles
UserRole.find_or_create_by!(user: super_admin_user, role: super_admin_role)
admin_role = Role.find_by(name: 'Admin')
UserRole.find_or_create_by!(user: admin_user, role: admin_role)

# Create Profiles for Users
puts "Creating Profiles for Users..."
super_admin_profile = super_admin_user.profile || super_admin_user.build_profile
super_admin_profile.assign_attributes(first_name: 'Super', last_name: 'Admin', gender: 1)

super_admin_profile.save!

admin_profile = admin_user.profile || admin_user.build_profile
admin_profile.assign_attributes(first_name: 'Arish', last_name: 'Thermic', gender: 1)
admin_profile.save!

puts "Seeding completed successfully!"
