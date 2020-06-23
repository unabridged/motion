# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/object/to_param"

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
        def broadcast_to(model, message)
          ActionCable.server.broadcast(broadcasting_for(model), message)
        end

        def stream_from(broadcast, handler)
          self._broadcast_handlers =
            _broadcast_handlers.merge(broadcast.to_s => handler.to_sym).freeze
        end

        def stream_for(model, handler)
          stream_from(broadcasting_for(model), handler)
        end

        def broadcasting_for(model)
          serialize_broadcasting([name, model])
        end

        private

        # Taken from ActionCable::Channel::Broadcasting
        def serialize_broadcasting(object)
          if object.is_a?(Array)
            object.map { |m| serialize_broadcasting(m) }.join(":")
          elsif object.respond_to?(:to_gid_param)
            object.to_gid_param
          else
            object.to_param
          end
        end
      end

      def broadcasts
        _broadcast_handlers.keys
      end

      def process_broadcast(broadcast, message)
        return unless (handler = _broadcast_handlers[broadcast])

        send(handler, message)
      end

      def broadcast_to(model, message)
        self.class.broadcast_to(model, message)
      end

      def stream_from(broadcast, handler)
        self._broadcast_handlers =
          _broadcast_handlers.merge(broadcast.to_s => handler.to_sym).freeze
      end

      def stream_for(model, handler)
        stream_from(self.class.broadcasting_for(model), handler)
      end

      private

      attr_writer :_broadcast_handlers

      def _broadcast_handlers
        return @_broadcast_handlers if defined?(@_broadcast_handlers)

        self.class._broadcast_handlers
      end
    end
  end
end
