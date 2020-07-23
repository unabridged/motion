# frozen_string_literal: true

require "motion"

module Motion
  module ActionCableExtentions
    # This module provides synchronization for the channel. This is required
    # because of the semantics introduced by having the handlers of streams
    # and broadcasts be instance methods.
    #
    # @api private
    module Synchronization
      # Ensures that only one thread is accessing the channel for the duration
      # of the provided block.
      #
      # @note
      #   This module covers the default ActionCable entrypoints, but any
      #   additional entrypoints to the channel (such as references to +self+
      #   inside of a +stream_from+ block) *must* be wrapped in a call to this
      #   method.
      def synchronize_entrypoint!(&block)
        @_monitor.synchronize(&block)
      end

      # This method is called by ActionCable when the channel is being setup.
      #
      # @private
      def subscribe_to_channel(*)
        synchronize_entrypoint! { super }
      end

      # This method is called by ActionCable when the channel is being shutdown.
      #
      # @private
      def unsubscribe_from_channel(*)
        synchronize_entrypoint! { super }
      end

      # This method is called by ActionCable when an action occurs.
      #
      # @private
      def perform_action(*)
        synchronize_entrypoint! { super }
      end

      private

      def initialize(*)
        super

        @_monitor = Monitor.new
      end
    end
  end
end
