# frozen_string_literal: true

require "spec_helper"

ENV["RAILS_ENV"] ||= "test"

require "rails"
require "model_explorer/engine"
require_relative "rails_app/config/environment"

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "capybara/rspec"

Capybara.register_driver(:selenium_chrome) do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[--disable-search-engine-choice-screen]
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.register_driver(:selenium_chrome_headless) do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[
      --headless=new
      --no-sandbox
      --disable-gpu
      --disable-search-engine-choice-screen
    ]
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.server = :webrick
Capybara.default_driver = ENV.fetch("CAPYBARA_DRIVER", "selenium_chrome").to_sym

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# In order to keep the same RAILS_ENV for rspec and cucumber, and to make rspec
# faster, patch the connection to use sqlite in memory when running rspec
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Schema.verbose = false
load "#{Rails.root}/db/schema.rb"

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.around(:each) do |example|
    I18n.with_locale(:fr) { example.run }
  end

  config.include ModelExplorer::Engine.routes.url_helpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :request
end
