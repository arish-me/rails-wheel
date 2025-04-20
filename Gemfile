source "https://rubygems.org"

gem "chartkick"
gem "groupdate"
gem "rails", "~> 8.0.1"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "pretender"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "devise"
gem "image_processing", ">= 1.2"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "lucide-rails"
gem "letter_opener"
gem "pagy"
gem "pg_search"
gem "pundit"
gem "tailwindcss-rails", "~> 3.1"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
gem "omniauth-github"
gem "view_component"
gem 'i18n'
gem 'geocoder'                                           # For geocoding and location services
gem 'countries'                                          # For country data and codes
# Background Jobs
gem "good_job"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "htmlbeautifier"
  gem "dotenv"
  gem "faker"                                            # Added for fake data generation
  gem "database_cleaner-active_record"                   # For cleaning the database in seed script
  gem "rspec-rails"                                      # RSpec testing framework
  gem "factory_bot_rails"                                # Factory pattern for test data
  gem "shoulda-matchers"                                 # Simplifies test validation
end

group :development do
  gem "hotwire-livereload"
  gem "web-console"
  gem "bullet"                                           # For N+1 query detection
  gem "rack-mini-profiler"                               # For performance profiling
  gem "memory_profiler"                                  # For memory profiling
  gem "stackprof"                                        # For CPU profiling
end

group :test do
  gem "capybara"                                         # Acceptance test framework
  gem "selenium-webdriver"                               # Browser automation for JS tests
  gem "webdrivers"                                       # Easy installation of browser drivers
  gem "rails-controller-testing"                         # Controller test helpers
end
