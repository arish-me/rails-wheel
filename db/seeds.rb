# This file calls our seed data services to populate the database
# The services are located in app/services/seed_data
# FAKER_COUNT=10 rails db:seed
# Get faker count from environment variable or use default
faker_count = ENV['FAKER_COUNT'] ? ENV['FAKER_COUNT'].to_i : nil
# faker_count = 100
# Call the main seeder service with the faker count

company = Company.find_or_create_by!(name: "TTC Servoce", subdomain: 'wheel.in')
ActsAsTenant.with_tenant(company) do
  SeedData::MainSeeder.new(faker_count, false, true, company).call
end
SeedData::PlatformUserService.new('serviceuser@wheel.com').call
SeedData::CandidateRoleService.call
