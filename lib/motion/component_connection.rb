# frozen_string_literal: true

require "motion"

module Motion
  # This class represents is to a component what a file handle is to a file. It
  # ties the lifecycle of the component to its own creation and destruction
  # firing the callbacks at the correct times and managing when rendering needs
  # to occur. It also acts as an error boundary for user code.
  #
  # @api private
  class ComponentConnection
    # Creates a component connection from the serialized state of a component
    #
    # @param state [String] the serialized state
    # @param serializer [optional, Motion::Serializer] the serializer to use
    # @param log_helper [optional, Motion::LogHelper] the log helper to use
    def self.from_state(
      state,
      serializer: Motion.serializer,
      log_helper: LogHelper.new,
      **kargs
    )
      component = serializer.deserialize(state)

      new(component, log_helper: log_helper.for_component(component), **kargs)
    end

    # @return [Motion::Component] the component that is currently connected
    attr_reader :component

    # @param component [Motion::Component] the component to connect
    # @param log_helper [optional, Motion::LogHelper] the log helper to use
    #
    # @note
    #   To connect a component from its serialized state, use
    #   {Motion::ComponentConnection.from_state}.
    def initialize(component, log_helper: LogHelper.for_component(component))
      @component = component
      @log_helper = log_helper

      timing("Connected") do
        @render_hash = component.render_hash

        component.process_connect
      end
    end

    # Close the current connection to a component.
    #
    # @note Once the connection is closed it should not be used anymore.
    def close
      timing("Disconnected") do
        component.process_disconnect
      end

      true
    rescue => error
      handle_error(error, "disconnecting the component")

      false
    end

    # Handle an incoming motion for the component.
    #
    # @param motion [String] the motion to process
    # @param event [optional, Motion::Event] an event associated with the motion
    def process_motion(motion, event = nil)
      timing("Proccessed #{motion}") do
        component.process_motion(motion, event)
      end

      true
    rescue => error
      handle_error(error, "processing #{motion}")

      false
    end

    # Handle an incoming broadcast for the component.
    #
    # @param broadcast [String] the broadcast
    # @param message [optional] the message
    def process_broadcast(broadcast, message)
      timing("Proccessed broadcast to #{broadcast}") do
        component.process_broadcast broadcast, message
      end

      true
    rescue => error
      handle_error(error, "processing a broadcast to #{broadcast}")

      false
    end

    # Handle a periodic timer firing for the component.
    #
    # @param periodic_timer [String] the periodic timer that is firing
    def process_periodic_timer(periodic_timer)
      timing("Proccessed periodic timer #{periodic_timer}") do
        component.process_periodic_timer periodic_timer
      end

      true
    rescue => error
      handle_error(error, "processing periodic timer #{periodic_timer}")

      false
    end

    # Checks if the component needs to be rendered, and if it does, yields the
    # component to the provided block for rendering.
    #
    # @yield [component]
    # @yieldparam component [Motion::Component] the component to render
    #
    # @note
    #   This method assumes that the provided block actually renders the
    #   component. If it does not, the connection will go into a bad state.
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

    # @return [Array<String>]
    #   the broadcasts the component is interested in
    def broadcasts
      component.broadcasts
    end

    # @return [Hash<String, Integer>]
    #   the timers the component would like to recevie
    def periodic_timers
      component.periodic_timers
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
