# frozen_string_literal: true

require "motion"

module Motion
  class Callback
    attr_reader :broadcast

    NAMESPACE = "motion:callback"
    private_constant :NAMESPACE

    def self.broadcast_for(component, method)
      [
        NAMESPACE,
        component.stable_instance_identifier_for_callbacks,
        method
      ].join(":")
    end

    def initialize(component, method)
      @broadcast = self.class.broadcast_for(component, method)

      component.stream_from(broadcast, method)
    end

    def ==(other)
      other.is_a?(Callback) &&
        other.broadcast == broadcast
    end

    def call(message = nil)
      ActionCable.server.broadcast(broadcast, message)
    end
  end
end
