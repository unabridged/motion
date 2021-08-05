# frozen_string_literal: true

require "active_support/concern"
require "motion"

module Motion
  module Component
    module Rendering
      extend ActiveSupport::Concern

      DEFAULT_IVARS = %i[
        @_stable_instance_identifier_for_callbacks
      ].freeze

      # Analogous to `module_function` (available on both class and instance)
      module ModuleFunctions
        def serializes(*ivars)
          self._serialized_ivars = _serialized_ivars + ivars.map do |ivar|
            ivar.to_s.starts_with?('@') ? ivar.to_sym : "@#{ivar}".to_sym
          end
        end

        def serialized_ivars
          _serialized_ivars
        end
      end

      class_methods do
        include ModuleFunctions

        attr_writer :_serialized_ivars

        def _serialized_ivars
          return @_serialized_ivars if defined?(@_serialized_ivars)
          return superclass._serialized_ivars if superclass.respond_to?(:_serialized_ivars)

          DEFAULT_IVARS
        end
      end

      include ModuleFunctions

      def rerender!
        @_awaiting_forced_rerender = true
      end

      def awaiting_forced_rerender?
        @_awaiting_forced_rerender
      end

      # * This can be overwritten.
      # * It will _not_ be sent to the client.
      # * If it doesn't change every time the component's state changes,
      #   things may fall out of sync unless you also call `#rerender!`
      def render_hash
        Motion.serializer.weak_digest(self)
      end

      def render_in(view_context)
        raise BlockNotAllowedError, self if block_given?

        html =
          _run_action_callbacks(context: :render) {
            _clear_awaiting_forced_rerender!

            view_context.capture { super }
          }

        raise RenderAborted, self unless html

        Motion.markup_transformer.add_state_to_html(self, html)
      end

      private

      attr_writer :_serialized_ivars

      def _serialized_ivars
        return @_serialized_ivars if defined?(@_serialized_ivars)

        self.class._serialized_ivars
      end

      def _clear_awaiting_forced_rerender!
        @_awaiting_forced_rerender = false
      end

      def marshal_dump
        _serialized_ivars
          .map { |ivar| [ivar, instance_variable_get(ivar)] }
          .to_h
      end

      def marshal_load(instance_variables)
        instance_variables.each do |ivar, value|
          instance_variable_set(ivar, value)
        end
      end
    end
  end
end
