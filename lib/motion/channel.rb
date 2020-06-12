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
    end

    def unsubscribed
      component.disconnected
      flush_component
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

    attr_reader :component

    def initialize_component
      @component = Motion.serializer.deserialize(params.fetch(:state))

      # Intentionally don't `render_component` here because the client's markup
      # matches their state.
      setup_broadcasts

      @render_hash = calculate_render_hash
    end

    def flush_component
      return if @render_hash == (next_render_hash = calculate_render_hash)

      render_component
      setup_broadcasts

      @render_hash = next_render_hash
    end

    def setup_broadcasts
      streaming_from(component.broadcasts)
    end

    def render_component
      transmit(Motion.renderer_for(connection).render(component))
    end

    def calculate_render_hash
      Motion.serializer.digest(component)
    end
  end
end
