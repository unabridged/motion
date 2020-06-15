# frozen_string_literal: true

require "action_cable/channel"

require "motion"
require "motion/channel/declarative_streams"

module Motion
  class Channel < ApplicationCable::Channel
    include DeclarativeStreams

    def subscribed
      assert_compatible_client!

      initialize_component

      component.connected
      flush_component
    end

    def unsubscribed
      component.disconnected

      # Intentionally don't `flush_component` here because there is nowhere to
      # send it. The channel is closed.
    end

    def process_action(data)
      action = data.fetch("name")
      event = data["event"]

      component.process_action(action, event)
      flush_component
    end

    private

    def process_broadcast(broadcast, message)
      component.process_broadcast(broadcast, message)
      flush_component
    end

    def assert_compatible_client!
      return if Motion::VERSION == (client_version = params.fetch(:version))

      raise IncompatibleClientError.new(Motion::VERSION, client_version)
    end

    attr_reader :component

    def initialize_component
      @component = Motion.serializer.deserialize(params.fetch(:state))

      # Intentionally don't `render_component` here because the client's markup
      # matches the state they just provided (that's where they got it!).
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
  end
end
