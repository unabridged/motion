# frozen_string_literal: true

require "capybara"
require "selenium/webdriver"

# See https://docs.travis-ci.com/user/chrome#capybara for details.
Capybara.register_driver :headless_chrome_no_sandbox do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: Selenium::WebDriver::Chrome::Options.new(
      args: %w[
        no-sandbox
        headless
        disable-gpu
      ]
    )
  )
end

Capybara.javascript_driver = :headless_chrome_no_sandbox
