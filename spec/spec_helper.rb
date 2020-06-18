# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "bundler/setup"

require "pry"
require "rails"
require "action_cable"
require "action_controller"
require "action_view"
require "rspec/rails"
require "view_component"
require "motion"

if Rails.version.to_f < 6.1
  require "view_component/render_monkey_patch"
  require "view_component/rendering_monkey_patch"
  require "view_component/render_to_string_monkey_patch"

  ActionView::Base.prepend ViewComponent::RenderMonkeyPatch
  ActionController::Base.prepend ViewComponent::RenderingMonkeyPatch
  ActionController::Base.prepend ViewComponent::RenderToStringMonkeyPatch
end

class TestApplication < Rails::Application
  secrets.secret_key_base = "test-secret-key-base"
end

class ApplicationController < ActionController::Base
end

module ApplicationCable
  class Connection < ActionCable::Connection::Base
  end

  class Channel < ActionCable::Channel::Base
  end
end

Rails.logger = Logger.new(File::NULL)

ActionCable.server.config.cable = {
  "adapter" => "test"
}

ActionCable.server.config.logger = Logger.new(File::NULL)

Motion.configure do |config|
  config.revision = "test-revision"

  # The default implimentation is not compatible with `ConnectionStub` which
  # does not have an underlying request or env, so we just use the main renderer
  # directly.
  config.renderer_for_connection_proc = ->(_connection) do
    ApplicationController.renderer
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
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
