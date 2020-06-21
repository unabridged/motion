# frozen_string_literal: true

Motion.configure do |config|
  config.revision = "test-revision"

  # The default implimentation is not compatible with `ConnectionStub` which
  # does not have an underlying request or env, so we just use the main renderer
  # directly for most specs.
  config.renderer_for_connection_proc = ->(_connection) do
    ApplicationController.renderer
  end
end
