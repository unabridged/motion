# frozen_string_literal: true

module SystemTestHelpers
  # https://bloggie.io/@kinopyo/capybara-trigger-blur-event
  def blur
    find("body").click
  end

  # TODO: Figure out how to get this information from the Motion client
  def wait_until_component_connected!
    sleep(Capybara.default_max_wait_time)
  end

  # TODO: Figure out how to get this information from the Motion client
  def wait_until_component_rendered!
    sleep(Capybara.default_max_wait_time)
  end
end
