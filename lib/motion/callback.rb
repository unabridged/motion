# frozen_string_literal: true

require "motion"

module Motion
  # This class represents a callback from a child component to a parent. It is
  # created with {Motion::Component::Callbacks#bind} and invoked via
  # {Motion::Callback#call}.
  #
  # See {Motion::Component::Callbacks} for details.
  class Callback
    # @return [String]
    #   the broadcast channel that will be used internally by the callback
    #
    # @note
    #   The underlying broadcast is a technical detail and the implimentation of
    #   callbacks may change in a future release of Motion. To invoke the
    #   callback, prefer using `Motion::Callback#call` instead.
    #
    # @api private
    attr_reader :broadcast

    NAMESPACE = "motion:callback"
    private_constant :NAMESPACE

    # Gives the broadcast channel that will be used internally by the callback.
    #
    # @note
    #   In order to avoid rerending the component when the same callback is
    #   recreated in the template and to keep the construction of the {Callback}
    #   idempotent, it is important that this value is stable for a given
    #   component instance and method.
    #
    # @param component [Component]
    #   the component to which the callback should be delivered
    # @param method [Symbol]
    #   the method to wich the callback should be delivered
    #
    # @return [String] the broadcast topic for the callback
    #
    # @api private
    def self.broadcast_for(component, method)
      [
        NAMESPACE,
        component.stable_instance_identifier_for_callbacks,
        method
      ].join(":")
    end

    # @note
    #   Instances of {Motion::Callback} should be created via
    #   {Motion::Component::Callbacks#bind}.
    #
    # @param component [Motion::Component]
    #   the component to which the callback should be delivered
    # @param method [Symbol]
    #   the method to wich the callback should be delivered
    #
    # @api private
    def initialize(component, method)
      @broadcast = self.class.broadcast_for(component, method)

      component.stream_from(broadcast, method)
    end

    # Two {Motion::Callback} instances are equal when they have the same effect
    # (call the same handler on the same component instance).
    #
    # @return [Boolean]
    def ==(other)
      other.is_a?(Callback) &&
        other.broadcast == broadcast
    end

    # Asynchronously invokes the handle on the component that created the
    # {Motion::Callback} with an optinal +message+.
    #
    # @param message [optional]
    #   A message to deliver along with the callback. If the handler accepts
    #   an argument, it will receive this. It must be serializable to JSON.
    #
    # @return [void]
    def call(message = nil)
      ActionCable.server.broadcast(broadcast, message)
    end
  end
end
