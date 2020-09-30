# frozen_string_literal: true

require "timeout"

module SystemTestHelpers
  # https://bloggie.io/@kinopyo/capybara-trigger-blur-event
  def blur
    find("body").click
  end

  def wait_until_component_connected!(&block)
    wait_until_count!("window.connectedComponentCount", &block)
  end

  def wait_until_component_rendered!(&block)
    wait_until_count!("window.renderCount", &block)
  end

  private

  def wait_until_count!(expression)
    if block_given?
      target = page.evaluate_script(expression)

      yield
    else
      target = 0
    end

    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until page.evaluate_script(expression) > target
    end
  end
end
