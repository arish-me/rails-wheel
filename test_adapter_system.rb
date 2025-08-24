#!/usr/bin/env ruby

# Test script for Job Board Adapter System
# Run this with: rails runner test_adapter_system.rb

puts "🔌 Testing Job Board Adapter System"
puts "=" * 50

# Get the first integration
integration = JobBoardIntegration.first

if integration.nil?
  puts "❌ No integrations found. Please create an integration first."
  puts "   Go to: http://localhost:3000/job_board_integrations"
  exit
end

puts "✅ Found integration: #{integration.name} (#{integration.provider})"
puts "   Company: #{integration.company.name}"
puts "   Status: #{integration.status}"

# Check if adapter exists for this provider
if JobBoardAdapters::AdapterFactory.adapter_exists?(integration.provider)
  puts "✅ Adapter found for #{integration.provider}"
else
  puts "❌ No adapter found for #{integration.provider}"
  puts "   Available adapters: #{JobBoardAdapters::AdapterFactory.supported_providers.join(', ')}"
  exit
end

# Test 1: Create Adapter
puts "\n1. Creating Adapter..."
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
  puts "\n3. Fetching Jobs from #{integration.provider}..."
  jobs_result = adapter.fetch_jobs

  if jobs_result[:success]
    jobs = jobs_result[:data]
    puts "   ✅ Successfully fetched #{jobs.length} jobs"
    puts "   Total available: #{jobs_result[:total_count]}"
    puts "   Mean salary: #{jobs_result[:mean_salary]}"

    # Show first few jobs
    puts "\n   Sample Jobs:"
    jobs.first(3).each_with_index do |job_data, index|
      puts "   #{index + 1}. #{job_data['title']} at #{job_data.dig('company', 'display_name')}"
      puts "      Location: #{job_data.dig('location', 'display_name')}"
      puts "      Salary: #{job_data['salary_min']} - #{job_data['salary_max']} INR"
      puts "      Type: #{job_data['contract_type']} (#{job_data['contract_time']})"
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
      puts "   Location: #{transformed_job[:location]}"
      puts "   Company: #{transformed_job[:company_name]}"
      puts "   Salary: #{transformed_job[:salary_min]} - #{transformed_job[:salary_max]} #{transformed_job[:salary_currency]}"
    end
  else
    puts "   ❌ Failed to fetch jobs: #{jobs_result[:message]}"
    if jobs_result[:error]
      puts "   Error: #{jobs_result[:error]}"
    end
  end
end

# Test 5: Show Supported Fields
puts "\n5. Supported Fields for #{integration.provider}:"
supported_fields = adapter.supported_fields
supported_fields.each_with_index do |field, index|
  puts "   #{index + 1}. #{field}"
end

puts "\n🎯 Adapter System Test Complete!"
puts "\nKey Benefits:"
puts "1. Each job board has its own adapter"
puts "2. Handles different API structures automatically"
puts "3. Transforms data between local and external formats"
puts "4. Easy to add new job board providers"
puts "5. Consistent interface across all providers"

puts "\nTo add a new job board:"
puts "1. Create new adapter class (e.g., ArbeitnowAdapter)"
puts "2. Add to AdapterFactory::ADAPTERS hash"
puts "3. Implement required methods"
puts "4. Test with real API"
