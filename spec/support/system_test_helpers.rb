# frozen_string_literal: true

module SystemTestHelpers
  # https://bloggie.io/@kinopyo/capybara-trigger-blur-event
  def blur
    find("body").click
  end

  # See `spec/support/test_application/app/javascript/packs/application.js`:
  JS_CONNECT_COUNT = "window.connectCount"
  JS_RENDER_COUNT = "window.renderCount"

  # Blocks until a new component connects (since the last call)
  def wait_for_connect
    wait_for_action_cable_idle
    wait_for_expression_to_increase(JS_CONNECT_COUNT)
  end

  # Blocks until a component renders (since the last call)
  def wait_for_render
    wait_for_action_cable_idle
    wait_for_expression_to_increase(JS_RENDER_COUNT)
  end

  private

  def wait_for_action_cable_idle
    executor = ActionCable.server.worker_pool.executor

    block_until do
      executor.send(:synchronize) do
        executor.completed_task_count == executor.scheduled_task_count
      end
    end
  end

  def wait_for_expression_to_increase(expression)
    last_values = (@_wait_for_expression_to_increase_state ||= Hash.new(0))

    last_value = last_values[expression]
    new_value = nil

    block_until { (new_value = page.evaluate_script(expression)) > last_value }

    last_values[expression] = new_value
  end

  def block_until(max_wait_time: Capybara.default_max_wait_time)
    expiration = max_wait_time && Time.now + max_wait_time

    loop do
      break if yield

      raise "timeout: condition not met before expiration" if expiration&.past?

      # Let the scheduler know that we are in a tight loop and waiting for other
      # threads/processes to make progress.
      Thread.pass
    end
  end
end
