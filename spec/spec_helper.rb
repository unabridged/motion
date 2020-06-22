# frozen_string_literal: true

require "bundler/setup"

# Accurate coverage reports require SimpleCov to be required immediately.
require "simplecov"

SimpleCov.start do
  add_filter "/bin/"
  add_filter "/spec/"
end

# Require Pry early so that it is always avaliable.
require "pry"

require_relative "support/test_application"
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

  config.before(:each, type: :system) do
    # Ensure that the client JavaScript within the app is synced with the gem
    TestApplication.sync_motion_client!

    # Use headless Chrome for system tests
    driven_by :selenium_chrome_headless
  end

  # For most specs, we want Motion to be configured in a predictable way, but
  # when we are testing the configuration specifically, we need Motion in an
  # unconfigured state.
  config.around(:each, unconfigured: true) do |example|
    testing_configuration = Motion.config

    Motion.reset_internal_state_for_testing!

    RSpec::Mocks.with_temporary_scope do
      # Motion will whine about not being configured. This is expected and does
      # not need to clutter up the output while running these examples.
      allow_any_instance_of(Motion::Configuration).to receive(:warn)

      example.run
    end

    Motion.reset_internal_state_for_testing!(testing_configuration)
  end
end
