# frozen_string_literal: true

require "motion"

module Motion
  class ComponentConnection
    def self.from_state!(state, serializer: Motion.serializer, **options)
      new(serializer.deserialize(state), **options)
    end

    attr_reader :component

    def initialize(component, log_helper: LogHelper.new)
      @component = component
      @log_helper = log_helper.for_component(component)

      timing("Connected") do
        @render_hash = component.render_hash

        component.connected
      end
    end

    def close
      timing("Disconnected") do
        component.disconnected
      end

      true
    rescue => error
      handle_error(error, "disconnecting the component")

      false
    end

    def process_motion(motion, event = nil)
      timing("Proccessed #{motion}") do
        component.process_motion(motion, event)
      end

      true
    rescue => error
      handle_error(error, "processing #{motion}")

      false
    end

    def process_broadcast(broadcast, message)
      timing("Proccessed broadcast to #{broadcast}") do
        component.process_broadcast broadcast, message
      end

      true
    rescue => error
      handle_error(error, "processing a broadcast to #{broadcast}")

      false
    end

    def if_render_required(&block)
      timing("Rendered") do
        next_render_hash = component.render_hash

        return if @render_hash == next_render_hash &&
          !component.awaiting_forced_rerender?

        yield(component)

        @render_hash = next_render_hash
      end
    rescue => error
      handle_error(error, "rendering the component")
    end

    def broadcasts
      component.broadcasts
    end

    private

    attr_reader :log_helper

    def timing(context, &block)
      log_helper.timing(context, &block)
    end

    def handle_error(error, context)
      log_helper.error("An error occurred while #{context}", error: error)
    end
  end
end
