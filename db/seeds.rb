Role.create!(name: 'Admin')
Role.create!(name: 'User')
Role.create!(name: 'Recruiter')
Role.create!(name: 'Guest')

Permission.create!(name: 'Manage Users', resource: 'users')
Permission.create!(name: 'View Reports', resource: 'reports')

Permission.create!(name: 'Manage Categories', resource: 'categories')


User.create(email: 'thermic.arish@gmail.com', password: 'thermic.arish@gmail.com', password_confirmation: 'thermic.arish@gmail.com')