# frozen_string_literal: true

require "fileutils"

# Load the TestApplication environment into this Ruby process
require_relative "test_application/config/environment"

# Also, load the generators since some specs depend on those.
TestApplication.load_generators

# Add a helper method to sync the JavaScript in the test app with the outer gem.
def TestApplication.sync_motion_client!
  return if @synced_motion_client

  # Clear webpacker's cache (if it exists)
  cache_path = File.expand_path("tmp/cache", Rails.root)
  FileUtils.rm_r(cache_path) if File.exist?(cache_path)

  # Install the latest version of the client code into the test application.
  stdout, stderr, status =
    Open3.capture3(
      "bin/yarn add --force @unabridged/motion@../../..",
      chdir: File.expand_path(Rails.root)
    )

  unless status.success?
    short_output = [stdout, stderr].delete_if(&:empty?).join("\n\n")
    raise "Failed to sync @unabridged/motion! Yarn says:\n#{short_output}"
  end

  @synced_motion_client = true
end
