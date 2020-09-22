# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/hash/except"

require "motion"

module Motion
  module Component
    module Motions
      extend ActiveSupport::Concern

      # Analogous to `module_function` (available on both class and instance)
      module ModuleFunctions
        def map_motion(motion, handler = motion)
          self._motion_handlers =
            _motion_handlers.merge(motion.to_s => handler.to_sym).freeze
        end

        def unmap_motion(motion)
          self._motion_handlers =
            _motion_handlers.except(motion.to_s).freeze
        end

        def motions
          _motion_handlers.keys
        end
      end

      class_methods do
        include ModuleFunctions

        def _motion_handlers
          return @_motion_handlers if defined?(@_motion_handlers)
          @_motion_handlers = {}.freeze
        end

        def _motion_handlers=(value)
          @_motion_handlers = value
        end
      end

      include ModuleFunctions

      def process_motion(motion, event = nil)
        unless (handler = _motion_handlers[motion])
          raise MotionNotMapped.new(self, motion)
        end

        _run_action_callbacks(context: handler) do
          if method(handler).arity.zero?
            send(handler)
          else
            send(handler, event)
          end
        end
      end

      private

      attr_writer :_motion_handlers

      def _motion_handlers
        return @_motion_handlers if defined?(@_motion_handlers)

        self.class._motion_handlers
      end
    end
  end
end
