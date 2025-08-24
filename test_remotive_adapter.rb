#!/usr/bin/env ruby

# Test script for Remotive Adapter
# Run this with: rails runner test_remotive_adapter.rb

puts "🌐 Testing Remotive Adapter"
puts "=" * 50

# Create a test integration for Remotive
provider = JobBoardProvider.find_by(slug: "remotive")

if provider.nil?
  puts "❌ Remotive provider not found. Please seed providers first."
  exit
end

puts "✅ Found Remotive provider: #{provider.name}"
puts "   Description: #{provider.description}"
puts "   Auth Type: #{provider.auth_type}"
puts "   Base URL: #{provider.base_url}"

# Create a test integration
company = Company.first
if company.nil?
  puts "❌ No companies found. Please create a company first."
  exit
end

# Create or find integration
integration = JobBoardIntegration.find_or_create_by(
  company: company,
  provider: "remotive"
) do |int|
  int.name = "Remotive Test Integration"
  int.api_key = "public_api_no_key_needed"
  int.status = "active"
end

puts "✅ Using integration: #{integration.name}"
puts "   Company: #{integration.company.name}"
puts "   Status: #{integration.status}"

# Test 1: Create Adapter
puts "\n1. Creating Remotive Adapter..."
begin
  adapter = JobBoardAdapters::AdapterFactory.create(integration)
  puts "   ✅ Adapter created: #{adapter.class.name}"
rescue => e
  puts "   ❌ Failed to create adapter: #{e.message}"
  exit
end

# Test 2: Test Connection
puts "\n2. Testing Connection..."
connection_result = adapter.test_connection
puts "   Result: #{connection_result[:success] ? '✅ SUCCESS' : '❌ FAILED'}"
puts "   Message: #{connection_result[:message]}"

if connection_result[:error]
  puts "   Error: #{connection_result[:error]}"
end

# Test 3: Fetch Jobs (if connection successful)
if connection_result[:success]
  puts "\n3. Fetching Jobs from Remotive..."
  jobs_result = adapter.fetch_jobs

  if jobs_result[:success]
    jobs = jobs_result[:data]
    puts "   ✅ Successfully fetched #{jobs.length} jobs"
    puts "   Total available: #{jobs_result[:total_count]}"
    puts "   Job count: #{jobs_result[:job_count]}"

    # Show first few jobs
    puts "\n   Sample Jobs:"
    jobs.first(3).each_with_index do |job_data, index|
      puts "   #{index + 1}. #{job_data['title']} at #{job_data['company_name']}"
      puts "      Location: #{job_data['candidate_required_location']}"
      puts "      Type: #{job_data['job_type']} (#{job_data['category']})"
      puts "      Salary: #{job_data['salary']}"
      puts "      Tags: #{job_data['tags']&.join(', ')}"
      puts ""
    end

    # Test 4: Transform External Job
    puts "\n4. Testing Job Transformation..."
    if jobs.any?
      sample_job = jobs.first
      transformed_job = adapter.transform_external_job(sample_job)

      puts "   Original: #{sample_job['title']}"
      puts "   Transformed: #{transformed_job[:title]}"
      puts "   External ID: #{transformed_job[:external_job_id]}"
      puts "   Location: #{transformed_job[:location_attributes][:location_search]}"
      puts "   Salary: #{transformed_job[:salary_min]} - #{transformed_job[:salary_max]} #{transformed_job[:salary_currency]}"
      puts "   Role Type: #{transformed_job[:role_type]}"
      puts "   Remote Policy: #{transformed_job[:remote_policy]}"
      puts "   Description Length: #{transformed_job[:description]&.length || 0} characters"
    end
  else
    puts "   ❌ Failed to fetch jobs: #{jobs_result[:message]}"
    if jobs_result[:error]
      puts "   Error: #{jobs_result[:error]}"
    end
  end
end

# Test 5: Show Supported Fields
puts "\n5. Supported Fields for Remotive:"
supported_fields = adapter.supported_fields
supported_fields.each_with_index do |field, index|
  puts "   #{index + 1}. #{field}"
end

puts "\n🎯 Remotive Adapter Test Complete!"
puts "\nKey Features:"
puts "1. Public API - no authentication required"
puts "2. Remote jobs only"
puts "3. HTML description cleaning"
puts "4. Salary parsing (k, /hr formats)"
puts "5. Location extraction from candidate_required_location"
puts "6. Experience level detection from title/description"
puts "7. Rate limited to 4 requests per day (per their terms)"

puts "\nTo use in production:"
puts "1. Create integration with provider: 'remotive'"
puts "2. Set any dummy API key (not used)"
puts "3. Run sync to pull remote jobs"
puts "4. Monitor rate limits (max 4 requests/day)"
