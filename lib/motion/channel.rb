# frozen_string_literal: true

require "action_cable/channel"

require "motion"
require "motion/channel/declarative_streams"

module Motion
  class Channel < ApplicationCable::Channel
    include DeclarativeStreams

    def subscribed
      initialize_component

      component.connected
      flush_component
    ensure
      reject unless component
    end

    def unsubscribed
      component.disconnected
      # no `flush_component` here because the channel is closed
    end

    def process_motion(data)
      component.process_motion data.fetch("name"), Event.from_raw(data["event"])
      flush_component
    end

    private

    def process_broadcast(broadcast, message)
      component.process_broadcast broadcast, message
      flush_component
    end

    attr_reader :component

    def initialize_component
      assert_compatible_client!

      @component = Motion.serializer.deserialize(params.fetch(:state))

      # no `render_component` here because the initial markup was already sent
      setup_broadcasts

      @render_hash = component.render_hash
    end

    def flush_component
      next_render_hash = component.render_hash

      return if !component.awaiting_forced_rerender? &&
        @render_hash == next_render_hash

      render_component
      setup_broadcasts

      @render_hash = next_render_hash
    end

    def setup_broadcasts
      streaming_from(component.broadcasts, to: :process_broadcast)
    end

    def render_component
      transmit(renderer.render(component))
    end

    # Memoize the renderer on the connection so that it can be shared accross
    # all components. `ActionController::Renderer` is already thread-safe and
    # designed to be reused.
    def renderer
      connection.instance_eval do
        @_motion_renderer ||= Motion.build_renderer_for(self)
      end
    end

    def assert_compatible_client!
      return if Motion::VERSION == (client_version = params.fetch(:version))

      raise IncompatibleClientError.new(Motion::VERSION, client_version)
    end
  end
end
