# frozen_string_literal: true

require "action_cable"

require "motion"

module Motion
  class Channel < ActionCable::Channel::Base
    include ActionCableExtentions::DeclarativeNotifications
    include ActionCableExtentions::DeclarativeStreams
    include ActionCableExtentions::LogSuppression

    ACTION_METHODS = Set.new(["process_motion"]).freeze
    private_constant :ACTION_METHODS

    # Don't use the ActionCable huertistic for deciding what actions can be
    # called from JavaScript. Instead, hard-code the list so we can make other
    # methods public without worrying about them being called from JavaScript.
    def self.action_methods
      ACTION_METHODS
    end

    attr_reader :component_connection

    def subscribed
      state, client_version = params.values_at("state", "version")

      if Gem::Version.new(Motion::VERSION) < Gem::Version.new(client_version)
        raise IncompatibleClientError.new(Motion::VERSION, client_version)
      end

      @component_connection =
        ComponentConnection.from_state(state, log_helper: log_helper)

      synchronize
    rescue => error
      reject

      handle_error(error, "connecting a component")
    end

    def unsubscribed
      component_connection&.close

      @component_connection = nil
    end

    def process_motion(data)
      motion, raw_event = data.values_at("name", "event")

      component_connection.process_motion(motion, Event.from_raw(raw_event))
      synchronize
    end

    def process_broadcast(broadcast, message)
      component_connection.process_broadcast(broadcast, message)
      synchronize
    end

    def process_periodic_timer(timer)
      component_connection.process_periodic_timer(timer)
      synchronize
    end

    private

    def synchronize
      streaming_from component_connection.broadcasts,
        to: :process_broadcast

      periodically_notify component_connection.periodic_timers,
        via: :process_periodic_timer

      component_connection.if_render_required do |component|
        transmit(renderer.render(component))
      end
    end

    def handle_error(error, context)
      log_helper.error("An error occurred while #{context}", error: error)
    end

    def log_helper
      @log_helper ||= LogHelper.for_channel(self)
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
