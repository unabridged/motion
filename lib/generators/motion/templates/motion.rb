# frozen_string_literal: true

# TODO: Explain all the options.
Motion.configure do |config|
  # config.secret = Rails.application.key_generator.generate_key "motion:secret"

  # config.revision = `git rev-parse HEAD`.chomp

  # config.renderer_for_connection_proc = ->(websocket_connection) do
  #   ApplicationController.renderer.new(
  #     websocket_connection.env.slice(
  #       Rack::HTTP_COOKIE,
  #       Rack::RACK_SESSION,
  #     )
  #   )
  # end

  # config.stimulus_controller_identifier = "motion"
  # config.key_attribute = "data-motion-key"
  # config.state_attribute = "data-motion-state"
  # config.motion_attribute = "data-motion"
end
