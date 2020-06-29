# frozen_string_literal: true

Motion.configure do |config|
  # Motion needs to be able to uniquely identify the version of the running
  # version of your application. By default, the commit hash from git is used,
  # but depending on your deployment, this may not be available in production.
  #
  # If you are sure that git is available in your production enviorment, you can
  # uncomment this line:
  #
  #     config.revision = `git rev-parse HEAD`.chomp
  #
  # If git is not available in your production enviorment, you must identify
  # your application version some other way:
  #
  #     config.revision =
  #       ENV.fetch("MY_DEPLOYMENT_NUMBER") { `git rev-parse HEAD`.chomp }
  #
  # Using a value that does not change on every deployment will likely lead to
  # confusing errors if components are connected during a deployment.

  # This proc will be invoked by Motion in order to create a renderer for each
  # websocket connection. By default, your `ApplicationController` will be used
  # and the session/cookies **as they were when the websocket was first open**
  # will be available:
  #
  #     config.renderer_for_connection_proc = ->(websocket_connection) do
  #       ApplicationController.renderer.new(
  #         websocket_connection.env.slice(
  #           Rack::HTTP_COOKIE,
  #           Rack::RACK_SESSION,
  #         )
  #       )
  #     end

  # The data attributes used by Motion can be customized, but these values must
  # also be updated in the Ruby initializer:
  #
  #     config.key_attribute = "data-motion-key"
  #     config.state_attribute = "data-motion-state"
  #     config.motion_attribute = "data-motion"
  #
end
