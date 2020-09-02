# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_record/railtie"
require "action_cable/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "webpacker"

require "view_component/engine"
require "motion"

class TestApplication < Rails::Application
  config.root = File.expand_path("..", __dir__)

  config.secret_key_base = "test-secret-key-base"
  config.eager_load = true

  # Silence irrelevant deprecation warning in Rails 5.2
  if Rails::VERSION::MAJOR == 5
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Enable stdout logger
  config.logger = Logger.new($stdout)

  # Keep the logger quiet by default
  config.log_level = ENV.fetch("LOG_LEVEL", "ERROR")
end
