# frozen_string_literal: true

require "motion"

module Motion
  module ActionCableExtentions
    module Synchronization
      def initialize(*)
        super

        @_monitor = Monitor.new
      end

      # Additional entrypoints added by other modules should wrap any entry
      # points that they add with this.
      def synchronize_entrypoint!(&block)
        @_monitor.synchronize(&block)
      end

      # Synchronize all standard ActionCable entry points.
      def subscribe_to_channel(*)
        synchronize_entrypoint! { super }
      end

      def unsubscribe_from_channel(*)
        synchronize_entrypoint! { super }
      end

      def perform_action(*)
        synchronize_entrypoint! { super }
      end
    end
  end
end
