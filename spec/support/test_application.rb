# frozen_string_literal: true

# Load the TestApplication environment into this Ruby process
require_relative "test_application/config/environment"

# Also, load the generators since some specs depend on those.
TestApplication.load_generators

# Add a helper method to sync the motion-client JavaScript in the test app with
# the outer gem.
def TestApplication.sync_motion_client!
  return if @synced_motion_client

  # This is adapted from how Webpacker runs Webpack.
  stdout, stderr, status =
    Open3.capture3(
      "#{RbConfig.ruby} ./bin/yarn add --force motion-client@../../../client",
      chdir: File.expand_path(Rails.root)
    )

  unless status.success?
    short_output = [stdout, stderr].delete_if(&:empty?).join("\n\n")
    raise "Failed to sync motion-client! Yarn says:\n#{short_output}"
  end

  @synced_motion_client = true
end
