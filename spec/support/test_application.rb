# frozen_string_literal: true

# Load the TestApplication environment into this Ruby process
require_relative "test_application/config/environment"

# Also, load the generators since some specs depend on those.
TestApplication.load_generators

# Add a helper method to sync the JavaScript in the test app with the outer gem.
class << TestApplication
  def sync_motion_client!
    return if @synced_motion_client

    yarn! "--cwd", "../../..", "link"
    yarn! "link", "@unabridged/motion"
    yarn! "install"

    clear_webpacker_cache!

    @synced_motion_client = true
  end

  private

  def clear_webpacker_cache!
    webpacker_cache_path = File.expand_path("tmp/cache", Rails.root)
    FileUtils.rm_r(webpacker_cache_path) if File.exist?(webpacker_cache_path)
  end

  def yarn!(*args)
    stdout, stderr, status =
      Open3.capture3("bin/yarn", *args, chdir: Rails.root)

    unless status.success?
      short_output = [stdout, stderr].delete_if(&:empty?).join("\n\n")
      raise "Failed to `yarn #{args.join(" ")}`! Yarn says:\n#{short_output}"
    end
  end
end
