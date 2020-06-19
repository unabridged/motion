# frozen_string_literal: true

require "bundler/setup"
require "simplecov"
SimpleCov.start

ENV["RAILS_ENV"] ||= "test"

require "pry"
require "rails"
require "action_cable"
require "action_controller"
require "action_view"
require "rspec/rails"
require "generator_spec"

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

  load_generators
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

class TestComponent < ViewComponent::Base
  include Motion::Component

  # used by tests that want to know the initial motions
  STATIC_MOTIONS = %w[
    noop
    noop_with_event
    noop_without_event
    change_state
    force_rerender
    setup_dynamic_motion
    setup_dynamic_stream
    raise_error
  ].freeze

  # used by tests that want to know the initial broadcasts
  STATIC_BROADCASTS = %w[
    noop
    change_state
    force_rerender
    setup_dynamic_motion
    setup_dynamic_stream
    raise_error
  ].freeze

  # used by tests that want to have a component be upgraded
  UPGRADEABLE_REVISION = "upgradeable-revision"

  def self.upgrade_from(revision, instance)
    return super unless revision == UPGRADEABLE_REVISION

    new(count: instance.count)
  end

  attr_reader :count

  def initialize(connected: :noop, disconnected: :noop, count: 0)
    @connected = connected
    @disconnected = disconnected

    @count = count
  end

  def call
    content_tag(:div) { "The state has been changed #{@count} times." }
  end

  def connected
    public_send(@connected)
  end

  def disconnected
    public_send(@disconnected)
  end

  stream_from "noop", :noop
  map_motion :noop

  def noop(*)
  end

  map_motion :noop_with_event

  def noop_with_event(_event)
  end

  map_motion :noop_without_event

  def noop_without_event
  end

  stream_from "change_state", :change_state
  map_motion :change_state

  def change_state(*)
    @count += 1
  end

  stream_from "force_rerender", :force_rerender
  map_motion :force_rerender

  def force_rerender(*)
    rerender!
  end

  stream_from "setup_dynamic_motion", :setup_dynamic_motion
  map_motion :setup_dynamic_motion

  # used for tests that want to detect this dynamic motion being setup
  DYNAMIC_MOTION = "dynamic_motion"

  def setup_dynamic_motion(*)
    map_motion DYNAMIC_MOTION, :noop
  end

  stream_from "setup_dynamic_stream", :setup_dynamic_stream
  map_motion :setup_dynamic_stream

  # used for tests that want to detect this dynamic broadcast being setup
  DYNAMIC_BROADCAST = "dynamic_broadcast"

  def setup_dynamic_stream(*)
    stream_from DYNAMIC_BROADCAST, :noop
  end

  stream_from "raise_error", :raise_error
  map_motion :raise_error

  def raise_error(*)
    raise "Error from TestComponent"
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
