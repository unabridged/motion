# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/hash/except"

require "motion"

module Motion
  module Component
    module PeriodicTimers
      extend ActiveSupport::Concern

      # Analogous to `module_function` (available on both class and instance)
      module ModuleFunctions
        def every(interval, handler, name: handler)
          periodic_timer(name, handler, every: interval)
        end

        def periodic_timer(name, handler = name, every:)
          self._periodic_timers =
            _periodic_timers.merge(name.to_s => [handler.to_sym, every]).freeze
        end

        def stop_periodic_timer(name)
          self._periodic_timers =
            _periodic_timers.except(name.to_s).freeze
        end

        def periodic_timers
          _periodic_timers.transform_values { |_handler, interval| interval }
        end
      end

      included do
        class_attribute :_periodic_timers,
          instance_reader: false,
          instance_writer: false,
          instance_predicate: false,
          default: {}.freeze
      end

      class_methods do
        include ModuleFunctions
      end

      include ModuleFunctions

      def process_periodic_timer(name)
        return unless (handler, _interval = _periodic_timers[name])

        send(handler)
      end

      private

      attr_writer :_periodic_timers

      def _periodic_timers
        return @_periodic_timers if defined?(@_periodic_timers)

        self.class._periodic_timers
      end
    end
  end
end
