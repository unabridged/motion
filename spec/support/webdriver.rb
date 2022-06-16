# frozen_string_literal: true

require "capybara"
require "webdrivers"
require "webdrivers/chromedriver"

# See https://docs.travis-ci.com/user/chrome#capybara for details.
Capybara.register_driver :headless_chrome_no_sandbox do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    capabilities: Selenium::WebDriver::Chrome::Options.new(
      args: %w[
        no-sandbox
        headless
        disable-gpu
      ]
    )
  )
end

Capybara.javascript_driver = :headless_chrome_no_sandbox

# This is not a good solution, but I do not know a better one.
Capybara.default_max_wait_time = 5
