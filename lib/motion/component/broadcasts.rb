# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"

require "motion"

module Motion
  module Component
    module Broadcasts
      extend ActiveSupport::Concern

      included do
        class_attribute :_broadcast_handlers,
          instance_reader: false,
          instance_writer: false,
          instance_predicate: false,
          default: {}.freeze
      end

      class_methods do
        def stream_from(broadcast, handler)
          self._broadcast_handlers =
            _broadcast_handlers.merge(broadcast.to_s => handler.to_sym).freeze
        end
      end

      def broadcasts
        _broadcast_handlers.keys
      end

      def process_broadcast(broadcast, message)
        return unless (handler = _broadcast_handlers[broadcast])

        send(handler, message)
      end

      private

      def stream_from(broadcast, handler)
        self._broadcast_handlers =
          _broadcast_handlers.merge(broadcast.to_s => handler.to_sym).freeze
      end

      attr_writer :_broadcast_handlers

      def _broadcast_handlers
        return @_broadcast_handlers if defined?(@_broadcast_handlers)

        self.class._broadcast_handlers
      end
    end
  end
end
