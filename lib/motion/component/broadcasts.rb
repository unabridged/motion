# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/object/to_param"
require "active_support/core_ext/hash/except"

require "motion"

module Motion
  module Component
    module Broadcasts
      extend ActiveSupport::Concern

      # Analogous to `module_function` (available on both class and instance)
      module ModuleFunctions
        def stream_from(broadcast, handler)
          self._broadcast_handlers =
            _broadcast_handlers.merge(broadcast.to_s => handler.to_sym).freeze
        end

        def stop_streaming_from(broadcast)
          self._broadcast_handlers =
            _broadcast_handlers.except(broadcast.to_s).freeze
        end

        def stream_for(model, handler)
          stream_from(broadcasting_for(model), handler)
        end

        def stop_streaming_for(model)
          stop_streaming_from(broadcasting_for(model))
        end

        def broadcasts
          _broadcast_handlers.keys
        end
      end

      included do
        class_attribute :_broadcast_handlers,
          instance_reader: false,
          instance_writer: false,
          instance_predicate: false,
          default: {}.freeze
      end

      module ClassMethods
        include ModuleFunctions

        def broadcast_to(model, message)
          ActionCable.server.broadcast(broadcasting_for(model), message)
        end

        # @private
        def broadcasting_for(model)
          serialize_broadcasting([name, model])
        end

        private

        # This definition is copied from ActionCable::Channel::Broadcasting
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

      include ModuleFunctions

      # @api private
      def process_broadcast(broadcast, message)
        return unless (handler = _broadcast_handlers[broadcast])

        _run_action_callbacks(context: handler) do
          if method(handler).arity.zero?
            send(handler)
          else
            send(handler, message)
          end
        end
      end

      private

      def broadcasting_for(model)
        self.class.broadcasting_for(model)
      end

      attr_writer :_broadcast_handlers

      def _broadcast_handlers
        return @_broadcast_handlers if defined?(@_broadcast_handlers)

        self.class._broadcast_handlers
      end
    end
  end
end
