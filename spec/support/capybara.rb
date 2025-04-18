RSpec.configure do |config|
  # Include custom Capybara helpers for feature specs
  config.include Capybara::DSL, type: :feature
  config.include Capybara::RSpecMatchers, type: :feature
end

# Helper methods for Capybara tests
module CapybaraHelpers
  # Wait for AJAX requests to complete
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  rescue Capybara::NotSupportedByDriverError
    true
  end

  # Fill in form fields with JavaScript (useful for date pickers, etc.)
  def fill_in_with_js(selector, value)
    page.execute_script("document.querySelector('#{selector}').value = '#{value}'")
  end

  # Take a screenshot of the current page (useful for debugging)
  def take_screenshot(name = "screenshot")
    path = "tmp/screenshots/#{name}-#{Time.now.to_i}.png"
    FileUtils.mkdir_p(File.dirname(path))
    page.save_screenshot(path)
    puts "Screenshot saved to #{path}"
  end

  # Wait for page to load after a redirect
  def wait_for_page_load(timeout = 1)
    old_path = current_path
    start_time = Time.now
    while old_path == current_path && Time.now - start_time < timeout
      sleep(0.1)
    end
    sleep(0.5) # Additional small wait for page content to load
  end

  # Wait for specific content to appear
  def wait_for_content(content, timeout = 1)
    start_time = Time.now
    while !page.has_content?(content) && Time.now - start_time < timeout
      sleep(0.1)
    end
  end
end

# Include helpers in feature specs
RSpec.configure do |config|
  config.include CapybaraHelpers, type: :feature
end
