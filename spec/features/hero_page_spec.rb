require 'rails_helper'

RSpec.feature "Hero Page", type: :feature do
  scenario "User visits the hero page and sees all sections", js: true do
    visit root_path

    # Hero Section
    within('.hero-section') do
      expect(page).to have_content("Wheel")
      expect(page).to have_content("The Ultimate Rails Framework for Modern Applications")
      expect(page).to have_button("Get Started")
      expect(page).to have_link("Learn More")
    end

    # Features Section
    within('.features-section') do
      expect(page).to have_content("Features")

      # Authentication
      expect(page).to have_content("Authentication")
      expect(page).to have_content("Built-in secure authentication with Devise")
      expect(page).to have_content("OAuth integration with Google & GitHub")

      # User Management
      expect(page).to have_content("User Management")
      expect(page).to have_content("Role-based access control")
      expect(page).to have_content("Permission management")

      # UI Framework
      expect(page).to have_content("Modern UI")
      expect(page).to have_content("Tailwind CSS integration")
      expect(page).to have_content("Responsive design")

      # Hotwire Integration
      expect(page).to have_content("Hotwire")
      expect(page).to have_content("Turbo for page navigation")
      expect(page).to have_content("Stimulus for JavaScript behaviors")

      # Background Jobs
      expect(page).to have_content("Background Jobs")
      expect(page).to have_content("GoodJob for database-backed processing")

      # Additional Features
      expect(page).to have_content("Solid Stack")
      expect(page).to have_content("SolidCache for caching")
      expect(page).to have_content("SolidQueue for background jobs")
    end

    # Testimonials Section
    within('.testimonials-section') do
      expect(page).to have_content("Testimonials")
      # At least one testimonial
      expect(page).to have_css('.testimonial-card', minimum: 1)
    end

    # Getting Started Section
    within('.getting-started-section') do
      expect(page).to have_content("Getting Started")
      expect(page).to have_content("Installation")
      expect(page).to have_content("Documentation")
      expect(page).to have_link("Documentation", href: "/docs")
    end

    # Call to Action
    within('.cta-section') do
      expect(page).to have_content("Ready to Build Your Next Application?")
      expect(page).to have_button("Get Started Now")
    end

    # Footer
    within('footer') do
      expect(page).to have_content("© #{Date.current.year} Wheel")
      expect(page).to have_link("GitHub")
      expect(page).to have_link("Terms")
      expect(page).to have_link("Privacy")
    end
  end

  scenario "User clicks the 'Get Started' button and is taken to sign up page", js: true do
    visit root_path

    within('.hero-section') do
      click_button("Get Started")
    end

    # Should be redirected to sign in page
    expect(current_path).to eq("/users/sign_in")
    expect(page).to have_content("Sign in to your account")
  end

  scenario "User clicks 'Learn More' and page scrolls to features section", js: true do
    visit root_path

    within('.hero-section') do
      click_link("Learn More")
    end

    # Test that the page scrolled to features section
    # This is a bit tricky to test with Capybara, but we can check if the features section is visible
    expect(page).to have_css('.features-section.active', wait: 5)
  end
end
