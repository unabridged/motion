# frozen_string_literal: true

require "action_cable"

require "motion"

module Motion
  # This is the primary entrypoint to Motion from the JavaScript client. The
  # client will create a subscription to this channel.
  #
  # @note
  #   In order to support upgrading (see
  #   {Motion::Component::Lifecycle::ClassMethods#upgrade_from} for details),
  #   it is important that this channel is _backward_ compatible with the
  #   JavaScript client.
  #
  # @api private
  class Channel < ActionCable::Channel::Base
    include ActionCableExtentions::DeclarativeNotifications
    include ActionCableExtentions::DeclarativeStreams
    include ActionCableExtentions::LogSuppression

    ACTION_METHODS = Set.new(["process_motion"]).freeze
    private_constant :ACTION_METHODS

    # Invoked by ActionCable in order to determine which methdods are allowed
    # to be safely called from JavaScript. We use a hard-coded list instead of
    # the normal huertistic so we can make other methods public without worrying
    # about them being called by the client.
    #
    # @api private
    def self.action_methods
      ACTION_METHODS
    end

    # @return [Motion::ComponentConnection]
    #   the connection to the component being mounted by the channel
    #
    # @api private
    attr_reader :component_connection

    # Invoked by ActionCable when the subscription is created by the client.
    # Verifies compatiblity with the client and mounts the component.
    #
    # @api private
    def subscribed
      state, client_version = params.values_at("state", "version")

      assert_compatible_client_version!(client_version)

      @component_connection =
        ComponentConnection.from_state(state, log_helper: log_helper)

      synchronize
    rescue => error
      reject

      handle_error(error, "connecting a component")
    end

    # Invoked by ActionCable when the connection to the client is lost or
    # closed. Unmounts the component and prepares for shutdown.
    #
    # @api private
    def unsubscribed
      component_connection&.close

      @component_connection = nil
    end

    # Invoked by ActionCable when the client has a motion to process. Processes
    # the motion on the connected component (re-rending if nessisary).
    #
    # @param data [Hash] the raw message from the client
    #
    # @api private
    def process_motion(data)
      motion, raw_event = data.values_at("name", "event")

      component_connection.process_motion(motion, Event.from_raw(raw_event))
      synchronize
    end

    # Invoked by {Motion::ActionCableExtentions::DeclarativeStreams} when a
    # broadcast occurs that the connected component is streaming from (see
    # {Motion::Channel#synchronize} for details). Processes the broadcast on the
    # connected component (re-rending if nessisary).
    #
    # @param broadcast [String] the broadcast that occurred
    # @param message the message associated with the broadcast
    #
    # @api private
    def process_broadcast(broadcast, message)
      component_connection.process_broadcast(broadcast, message)
      synchronize
    end

    # Invoked by {Motion::ActionCableExtentions::DeclarativeNotifications} at
    # scheduled intervals (see {Motion::Channel#synchronize} for details).
    # Processes the periodic timer on the connected component (re-rending if
    # nessisary).
    #
    # @param timer [String] the timer that is firing
    #
    # @api private
    def process_periodic_timer(timer)
      component_connection.process_periodic_timer(timer)
      synchronize
    end

    private

    def assert_compatible_client_version!(client_version)
      return if Motion.compatible_client_version?(client_version)

      raise Errors::IncompatibleClientError.new(client_version)
    end

    def synchronize
      component_connection.if_render_required do |component|
        transmit(renderer.render(component))
      end

      streaming_from component_connection.broadcasts,
        to: :process_broadcast

      periodically_notify component_connection.periodic_timers,
        via: :process_periodic_timer
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
