# frozen_string_literal: true

require 'action_cable/channel'

require 'motion'

module Motion
  class Channel < ApplicationCable::Channel
    def initialize(*)
      @mutex = Mutex.new

      super
    end

    def subscribed
      synchronize do
        component.connected
      end

      setup_broadcasts
    end

    def unsubscribed
      synchronize do
        component.disconnected
      end
    end

    def process_action(data)
      action = data.fetch('name')
      event = data['event']

      synchronize do
        component.process_action(action, event)
      end

      render_component
      setup_broadcasts
    end

    private

    def process_broadcast(broadcast, message)
      synchronize do
        component.process_broadcast(broadcast, message)
      end

      render_component
      setup_broadcasts
    end

    def render_component
      transmit(
        synchronize do
          renderer.render(component)
        end
      )
    end

    def setup_broadcasts
      synchronize do
        (component.broadcasts - broadcasts).each do |broadcast|
          stream_from(broadcast) do |message|
            process_broadcast(broadcast, message)
          end
        end
      end
    end

    def synchronize(&block)
      @mutex.synchronize(&block)
    end

    def component
      @component ||= Motion.serializer.deserialize(params.fetch(:state))
    end

    def renderer
      @renderer ||= ApplicationController.renderer.with_defaults(renderer_env)
    end

    def renderer_env
      connection.env.slice(
        Rack::HTTP_COOKIE,
        Rack::RACK_SESSION,
        Rack::RACK_SESSION_OPTIONS,
        Rack::RACK_SESSION_UNPACKED_COOKIE_DATA
      )
    end

    def broadcasts
      streams.map { |broadcast, _handler| broadcast }
    end
  end
end
