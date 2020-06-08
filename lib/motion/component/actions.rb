# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/core_ext/class/attribute'

require 'motion'

module Motion
  module Component
    module Actions
      extend ActiveSupport::Concern

      included do
        class_attribute :_action_handlers,
                        instance_reader: false,
                        instance_writer: false,
                        instance_predicate: false,
                        default: {}.freeze
      end

      class_methods do
        def map_action(action, handler = action)
          self._action_handlers =
            _action_handlers.merge(action.to_s => handler.to_sym).freeze
        end
      end

      def actions
        _action_handlers.keys
      end

      def process_action(action, event = nil)
        unless (handler = _action_handlers[action])
          raise ActionNotMapped.new(self, action)
        end

        if method(handler).arity.zero?
          send(handler)
        else
          send(handler, event)
        end
      end

      private

      def map_action(action, handler = action)
        self._action_handlers =
          _action_handlers.merge(action.to_s => handler.to_sym).freeze
      end

      attr_writer :_action_handlers

      def _action_handlers
        return @_action_handlers if defined?(@_action_handlers)

        self.class._action_handlers
      end
    end
  end
end
