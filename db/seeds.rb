Role.create!(name: 'Admin')
Role.create!(name: 'User')
Role.create!(name: 'Recruiter')
Role.create!(name: 'Guest')

Permission.create!(name: 'Manage Users', resource: 'users')
Permission.create!(name: 'View Reports', resource: 'reports')

Permission.create!(name: 'Manage Categories', resource: 'categories')