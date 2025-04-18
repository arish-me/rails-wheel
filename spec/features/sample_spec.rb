require 'rails_helper'

# This is an example feature spec using Capybara
# Your real tests will be based on your application's functionality

RSpec.feature "Sample feature", type: :feature do
  # Add js: true when you need JavaScript support
  scenario "User visits the home page", js: true do
    visit root_path

    # Example assertions
    expect(page).to have_content("Wheel\nGet Started\nHome\nAbout\nServices\nContact")

    # Example interactions
    # click_link "Get Started"
    # fill_in "Email", with: "user@example.com"
    # fill_in "Password", with: "password"
    # click_button "Log in"

    # Wait for any AJAX requests to complete
    # wait_for_ajax

    # Example assertions after interaction
    # expect(page).to have_content("Dashboard")
    # expect(page).to have_css(".user-profile")

    # Example of taking a screenshot (useful for debugging)
    # take_screenshot("after_login")
  end
end
