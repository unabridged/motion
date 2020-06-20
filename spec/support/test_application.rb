# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
ENV["RACK_ENV"] ||= "test"
ENV["NODE_ENV"] ||= "test"

require "rails"
require "action_cable/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "webpacker"

require "view_component/engine"
require "motion"

class TestApplication < Rails::Application
  config.secret_key_base = "test-secret-key-base"
  config.eager_load = true

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false
end

class ApplicationController < ActionController::Base
  def test_component
    require_relative "test_component"

    render(inline: <<~ERB)
      <!DOCTYPE html>
      <html>
        <head>
          <%= csrf_meta_tags %>
          <%= csp_meta_tag %>

          <%= javascript_pack_tag 'application' %>
        </head>

        <body>
          <%= render TestComponent.new %>
        </body>
      </html>
    ERB
  end
end

module ApplicationCable
  class Connection < ActionCable::Connection::Base
  end

  class Channel < ActionCable::Channel::Base
  end
end

ActionCable.server.config.cable = {
  "adapter" => "test"
}

Motion.configure do |config|
  config.revision = "test-revision"

  # The default implimentation is not compatible with `ConnectionStub` which
  # does not have an underlying request or env, so we just use the main renderer
  # directly.
  config.renderer_for_connection_proc = ->(_connection) do
    ApplicationController.renderer
  end
end

# Silence any logging
Rails.logger = Logger.new(File::NULL)
ActionCable.server.config.logger = Logger.new(File::NULL)

TestApplication.initialize!
TestApplication.load_generators

TestApplication.routes.draw do
  get "/test_component" => "application#test_component"
end
