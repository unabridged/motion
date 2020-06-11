# frozen_string_literal: true

require "action_cable/channel"

require "motion"

module Motion
  class Channel < ApplicationCable::Channel
    def subscribed
      return reject unless initialize_component

      with_component do |component|
        component.connected
      end
    end

    def unsubscribed
      with_component do |component|
        component.disconnected
      end
    end

    def process_action(data)
      with_component do |component|
        action = data.fetch("name")
        event = data["event"]

        component.process_action(action, event)
      end
    end

    def process_broadcast(broadcast, message)
      with_component do |component|
        component.process_broadcast(broadcast, message)
      end
    end

    private

    def initialize_component
      @manager = ComponentStateManager.new(state: params.fetch(:state))

      @manager.flush do |component|
        streaming_from component.broadcasts
      end

      true
    rescue => error
      Motion.handle_error(error)

      false
    end

    def with_component(&block)
      return unless defined?(@manager)

      @manager.use(&block)

      html_to_flush = nil

      @manager.flush do |component|
        html_to_flush = Motion.renderer_for(connection).render(component)
        streaming_from component.broadcasts
      end

      transmit(html_to_flush) if html_to_flush
    rescue => error
      Motion.handle_error(error)
    end

    # TODO: Handle unsubscribing
    def streaming_from(target_broadcasts)
      (target_broadcasts - current_broadcasts).each do |broadcast|
        stream_from(broadcast) do |message|
          process_broadcast(broadcast, message)
        end
      end
    end

    def current_broadcasts
      streams.map { |broadcast, _handler| broadcast }
    end
  end
end
