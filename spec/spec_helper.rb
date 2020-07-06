# frozen_string_literal: true

require "bundler/setup"
require "pry"

# Accurate coverage reports require reporting to be started early.
require_relative "support/coverage_report"

# Sadly, we must always load the test application (even though many specs will
# never reference it) because `rspec/rails` uses the constants it defines to do
# intelligent feature detection.
require_relative "support/test_application"

# This needs to be required by `rspec/rails` to ensure that everything is setup
# properly. It only has an effect in Rails 5.
require_relative "support/action_cable_testing_workaround"

require "rspec/rails"
require "capybara/rspec"
require "generator_spec"

require_relative "support/test_component"
require_relative "support/webdriver"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Isolate any database effects
  config.use_transactional_fixtures = true

  # Isolate the effects of the generator specs to a temporary folder
  config.around(:each, type: :generator) do |example|
    Dir.mktmpdir do |path|
      self.destination_root = path
      prepare_destination

      example.run
    end
  end

  config.before(:each, type: :system) do
    # Ensure that the client JavaScript within the app is synced with the gem
    TestApplication.sync_motion_client!

    # Use headless Chrome for system tests
    driven_by :headless_chrome_no_sandbox
  end

  # For most specs, we want Motion to be configured in a predictable way, but
  # when we are testing the configuration specifically, we need Motion in an
  # unconfigured state.
  config.around(:each, unconfigured: true) do |example|
    testing_configuration = Motion.config

    Motion.reset_internal_state_for_testing!

    example.run

    Motion.reset_internal_state_for_testing!(testing_configuration)
  end
end
