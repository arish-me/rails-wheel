#!/usr/bin/env ruby

# Test script for Bidirectional Job Board Sync
# Run this with: rails runner test_bidirectional_sync.rb

puts "🔄 Testing Bidirectional Job Board Sync"
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

# Test 1: Test Connection
puts "\n1. Testing Connection..."
service = JobBoardSyncService.new(integration)
connection_result = service.test_connection
puts "   Result: #{connection_result[:success] ? '✅ SUCCESS' : '❌ FAILED'}"
puts "   Message: #{connection_result[:message]}"

# Test 2: Bidirectional Sync (Pull from External Board)
puts "\n2. Testing Bidirectional Sync..."
puts "   This will:"
puts "   - Pull jobs from #{integration.provider}"
puts "   - Compare with local jobs"
puts "   - Create new jobs if they don't exist"
puts "   - Update existing jobs if they've changed"
puts "   - Skip unchanged jobs"

sync_result = service.sync_all_jobs
puts "   Result: #{sync_result[:success] ? '✅ SUCCESS' : '❌ FAILED'}"
puts "   Message: #{sync_result[:message]}"

# Test 3: Check Sync Logs
puts "\n3. Recent Sync Logs..."
logs = integration.job_board_sync_logs.recent.limit(5)
if logs.any?
  logs.each do |log|
    status_icon = case log.status
    when 'success' then '✅'
    when 'error' then '❌'
    when 'warning' then '⚠️'
    else 'ℹ️'
    end
    puts "   #{status_icon} #{log.action}: #{log.message}"
  end
else
  puts "   No sync logs found"
end

# Test 4: Show Job Counts
puts "\n4. Job Counts..."
local_jobs = integration.company.jobs.count
external_jobs = integration.company.jobs.where(external_source: integration.provider).count
puts "   Local jobs: #{local_jobs}"
puts "   External jobs: #{external_jobs}"

puts "\n🎯 Bidirectional Sync Test Complete!"
puts "\nHow it works:"
puts "1. sync_all_jobs() pulls jobs from external board"
puts "2. Compares each job with local database"
puts "3. Creates new jobs if they don't exist"
puts "4. Updates existing jobs if they've changed"
puts "5. Skips jobs that haven't changed"
puts "6. Logs all actions for monitoring"

puts "\nTo test with real data:"
puts "1. Create some jobs in your system"
puts "2. Configure field mappings properly"
puts "3. Run the sync again"
puts "4. Check the sync logs for details"
