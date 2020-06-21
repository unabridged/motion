# frozen_string_literal: true

# This is adapted from how Webpacker runs Webpack.
stdout, stderr, status = Open3.capture3(
  "#{RbConfig.ruby} ./bin/yarn add --force motion-client@../../../client",
  chdir: File.expand_path(Rails.root)
)

if status.success?
  Rails.logger.info "Successfully synced motion-client!"
else
  short_output = [stdout, stderr].delete_if(&:empty?).join("\n\n")

  Rails.logger.error("Failed to sync motion-client!")
  Rails.logger.error("Yarn says:\n#{short_output}")
end
