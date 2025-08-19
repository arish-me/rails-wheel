# This file calls our seed data services to populate the database
# The services are located in app/services/seed_data
# FAKER_COUNT=10 rails db:seed
# Get faker count from environment variable or use default
faker_count = ENV['FAKER_COUNT'] ? ENV['FAKER_COUNT'].to_i : nil
# faker_count = 100
# Call the main seeder service with the faker count
puts "🌐 Creating Default company"
company = Company.find_or_create_by!(name: "TTC Service", subdomain: 'wheel.in', website: 'www.wheel.in')
puts "🌐 Finish Creating Default company"
ActsAsTenant.with_tenant(company) do
  puts "🌐 Running MainSeeder"
  SeedData::MainSeeder.new(faker_count, false, true, company).call
  puts "🌐 Finish MainSeeder"
end
puts "🌐 Creating PlatformUser"
SeedData::PlatformUserService.new('serviceuser@wheel.com').call

puts "🌐 Creating Candidate Roles"
SeedData::CandidateRoleService.call
puts "🌐 Creating Skills"
SeedData::SkillService.call

puts "🌐 Seeding Candidates.."
puts "👥 Seeding candidate data..."
SeedData::CandidateDataSeeder.new(10).call

puts "🌐 Seeding Jobs.."
company = Company.find_by(name: "TTC Service")
if company
  puts "📋 Seeding real job data..."
  SeedData::RealJobDataSeeder.new(company, 5).call
end


# # Seed job board providers
# load(Rails.root.join('db', 'seeds', 'job_board_providers.rb'))

# # Seed job portal data
# puts "🌐 Seeding job portal data..."
# company = Company.find_by(name: "TTC Service")
# if company
#   # Seed real job data first
#   puts "📋 Seeding real job data..."
#   SeedData::RealJobDataSeeder.new(company, 20).call

#   # Import external job data
#   puts "🌐 Importing external job data..."
#   SeedData::RealJobImportService.new(company, keywords: 'developer', location: 'San Francisco', limit: 5).call

#   # Seed job applications
#   puts "📝 Seeding job applications..."
#   SeedData::JobApplicationSeeder.new(company, 30).call

#   # Seed job board integrations and sync logs
#   puts "🔗 Seeding job board integrations..."
#   SeedData::JobPortalSeeder.new(company, 0).call # Only integrations and logs, no jobs
# else
#   puts "⚠️ Company 'TTC Service' not found, skipping job portal seeding"
# end
