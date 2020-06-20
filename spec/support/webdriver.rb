# frozen_string_literal: true

require "capybara"
require "selenium/webdriver"

Capybara.javascript_driver = :selenium_chrome_headless
