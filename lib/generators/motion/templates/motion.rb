# frozen_string_literal: true

# TODO: Explain all the options.
Motion.configure do |config|
  # config.secret = Rails.application.key_generator.generate_key "motion:secret"

  # config.revision = `git rev-parse HEAD`.chomp

  # config.renderer_for_connection_proc = ->(connection) do
  #   ApplicationController.renderer.new(
  #     connection.env.slice(
  #       Rack::HTTP_COOKIE,
  #       Rack::RACK_SESSION,
  #       Rack::RACK_SESSION_OPTIONS,
  #       Rack::RACK_SESSION_UNPACKED_COOKIE_DATA
  #     )
  #   )
  # end
end
