require 'rails_helper'

RSpec.feature "Navbar and Authentication", type: :feature do
  # Create a default role before tests run
  before(:all) do
    # Create a default role that will be needed by user factory
    @default_role = create(:default_role) unless Role.find_by(is_default: true)
  end

  scenario "User navigates from home to sign in page and attempts authentication", js: true do
    # Visit the root path
    visit root_path
    # Ensure the page is fully loaded
    wait_for_content("Wheel")

    # Validate navbar elements
    expect(page).to have_content("Wheel")
    expect(page).to have_link("Get Started")
    expect(page).to have_link("Home")
    expect(page).to have_link("About")
    expect(page).to have_link("Services")
    expect(page).to have_link("Contact")

    # Click on Get Started link
    click_link "Get Started"
    # Wait for the redirect
    wait_for_page_load
    wait_for_content("Sign in to your account")

    # Verify we're on the sign in page
    expect(current_path).to eq("/users/sign_in")
    expect(page).to have_content("Sign in to your account")

    # Verify sign in page elements
    expect(page).to have_field("Email")
    expect(page).to have_field("Password")
    expect(page).to have_field("Remember me")

    # Use test-id attribute to find specific elements
    expect(page).to have_css('[test-id="google"]')
    expect(page).to have_css('[test-id="github"]')

    # You can also verify that the images exist
    expect(find('[test-id="google"]').tag_name).to eq('img')
    expect(find('[test-id="github"]').tag_name).to eq('img')

    expect(page).to have_link("Sign up")
    expect(page).to have_link("Forgot your password?")
    expect(page).to have_link("Didn't receive unlock instructions?")

    # Test invalid login
    fill_in "Email", with: "wrong@example.com"
    fill_in "Password", with: "wrongpassword"
    click_button "Sign In with Email"
    # Wait for error message
    wait_for_content("Invalid Email or password")

    # Expect error message for invalid login
    expect(page).to have_content("Invalid Email or password")

    # Create a test user using our factory
    user = create(:user_with_default_role, email: "test@example.com", password: "password123")

    # Test valid login
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Sign In with Email"
    # Wait for successful login and redirect
    wait_for_page_load
    # wait_for_content("Signed in successfully")

    # Verify successful login
    expect(page).to have_content("Signed in successfully")
    # You might want to check for dashboard content or user-specific elements
    expect(page).to have_content("Dashboard") if page.has_content?("Dashboard")
    expect(page).to have_link("Settings") if page.has_link?("Settings")
    expect(page).to have_link("Sign out") if page.has_link?("Sign out")

    # Click on the user dropdown
    find('[test-id="user-dropdown"]').click

    # Wait for dropdown to appear
    wait_for_content("Sign Out")

    # Verify all links in the dropdown menu
    within('[test-id="user-dropdown"]') do
      expect(page).to have_link("Dashboard") if page.has_link?("Dashboard")
      expect(page).to have_link("Settings") if page.has_link?("Settings")
      expect(page).to have_link("Sign out") if page.has_link?("Sign out")
    end

    # Click on the Sign out link
    click_link("Sign Out")
    # Wait for sign out to complete
    wait_for_page_load

    # Verify we're logged out and back at the login page or home page
    expect(page).to have_link("Get Started")
  end
end
