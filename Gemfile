source 'https://rubygems.org'

gem 'acts_as_tenant'
gem 'bootsnap', require: false
gem 'chartkick'
gem 'countries' # For country data and codes
gem 'devise', '~> 4.9', '>= 4.9.4'
gem 'devise_invitable', '~> 2.0.0'
gem 'geocoder'
gem 'groupdate'
gem 'i18n'
gem 'image_processing', '>= 1.2'
gem 'importmap-rails'
gem 'jbuilder'
gem 'kamal', require: false
gem 'letter_opener'
gem 'lucide-rails'
gem 'noticed' # For handling notifications
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'pagy'
gem 'pg', '~> 1.1'
gem 'pg_search'
gem 'pretender'
gem 'propshaft'
gem 'puma', '>= 5.0'
gem 'pundit'
gem 'rails', '~> 8.0.1'
gem 'solid_cable'
gem 'solid_cache'
gem 'solid_queue'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'thruster', require: false
gem 'timezone_finder' # For geocoding and location services
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[windows jruby]
gem 'view_component'
# Background Jobs
gem 'classy-yaml'
gem 'email_validator'
gem 'friendly_id'
gem 'good_job'
gem 'hashid-rails'
gem 'hotwire_combobox'
gem 'httparty'
gem 'inline_svg'
gem 'phony_rails'
gem 'redcarpet'
gem 'whenever', require: false

group :development, :test do
  gem 'brakeman', require: false
  gem 'database_cleaner-active_record'                   # For cleaning the database in seed script
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'dotenv'
  gem 'factory_bot_rails'                                # Factory pattern for test data
  gem 'faker'                                            # Added for fake data generation
  gem 'htmlbeautifier'
  gem 'rspec-rails'                                      # RSpec testing framework
  gem 'rubocop-rails-omakase', require: false
  gem 'shoulda-matchers'                                 # Simplifies test validation
end

group :development do
  gem 'bullet'                                           # For N+1 query detection
  gem 'hotwire-livereload'
  gem 'memory_profiler'                                  # For memory profiling
  gem 'rack-mini-profiler'                               # For performance profiling
  gem 'stackprof'                                        # For CPU profiling
  gem 'web-console'
end

group :test do
  gem 'capybara'                                         # Acceptance test framework
  gem 'rails-controller-testing'                         # Controller test helpers
  gem 'selenium-webdriver'
  gem 'simplecov', require: false # Browser automation for JS tests
  gem 'webdrivers' # Easy installation of browser drivers
end

gem 'erb-formatter', '~> 0.7.3', group: :development
