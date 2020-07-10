# frozen_string_literal: true

Motion.configure do |config|
  # Motion needs to be able to uniquely identify the version of the running
  # version of your application. By default, the commit hash from git is used,
  # but depending on your deployment, this may not be available in production.
  #
  # Motion automatically calculates your revision by hashing the contents of
  # files in `revision_paths` The defaults revision paths are:
  # rails paths, bin, and Gemfile.lock.
  #
  # To change or add to your revision paths, uncomment this line:
  #
  #     config.revision_paths += w(additional_path another_path)
  #
  # If you prefer to use git or an environmental variable for the revision
  # in production, define the revision directly below.
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
  #           Rack::HTTP_COOKIE,  # Cookies
  #           Rack::RACK_SESSION, # Session
  #           'warden'            # Warden (needed for `current_user` in Devise)
  #         )
  #       )
  #     end

  # This proc will be invoked by Motion when an unhandled error occurs. By
  # default, an error is logged to the application's default logger but no
  # additional action is taken. If you are using an error tracking tool like
  # Bugsnag, Sentry, Honeybadger, or Rollbar, you can provide a proc which
  # notifies that as well:
  #
  #     config.error_notification_proc = ->(error, message) do
  #       Bugsnag.notify(error) do |report|
  #         report.add_tab(:motion, {
  #           message: message
  #         })
  #       end
  #     end

  # The data attributes used by Motion can be customized, but these values must
  # also be updated in the JavaScript client configuration:
  #
  #     config.key_attribute = "data-motion-key"
  #     config.state_attribute = "data-motion-state"
  #     config.motion_attribute = "data-motion"
  #
end
