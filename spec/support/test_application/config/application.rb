# frozen_string_literal: true

require_relative "boot"

require "rails"
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

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Enable stdout logger
  config.logger = Logger.new(STDOUT)

  # Keep the logger quiet by default
  config.log_level = ENV.fetch("LOG_LEVEL", "ERROR")
end
