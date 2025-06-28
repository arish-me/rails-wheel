RSpec.configure do |config|
  # Check for custom flags
  capybara_mode = ARGV.include?('--capybara') || ARGV.include?('--automation')
  
  if capybara_mode
    # Run only feature tests
    config.filter_run_including type: :feature
    puts "🐛 Running Capybara feature tests only..."
  else
    # Run only unit tests (exclude feature tests)
    config.filter_run_excluding type: :feature
    puts "⚡ Running unit tests only (excluding feature tests)..."
  end
end 