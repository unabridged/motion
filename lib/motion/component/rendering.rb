# frozen_string_literal: true

require "motion"

module Motion
  module Component
    module Rendering
      # Use the presence/absence of the ivar instead of true/false to avoid
      # extra serialized state (Note that in this scheme, the presence of
      # the ivar will never be serialized).
      RERENDER_MARKER_IVAR = :@__awaiting_forced_rerender__
      private_constant :RERENDER_MARKER_IVAR

      # Some changes to Motion's state are specifically supported during render.
      ALLOWED_NEW_IVARS_DURING_RENDER = %i[
        @_broadcast_handlers
        @_stable_instance_identifier_for_callbacks
        @_motion_handlers
        @_periodic_timers
      ].freeze
      private_constant :ALLOWED_NEW_IVARS_DURING_RENDER

      def rerender!
        instance_variable_set(RERENDER_MARKER_IVAR, true)
      end

      def awaiting_forced_rerender?
        instance_variable_defined?(RERENDER_MARKER_IVAR)
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

            view_context.capture { _without_new_instance_variables { super } }
          }

        raise RenderAborted, self if html == false

        Motion.markup_transformer.add_state_to_html(self, html)
      end

      private

      def _clear_awaiting_forced_rerender!
        return unless awaiting_forced_rerender?

        remove_instance_variable(RERENDER_MARKER_IVAR)
      end

      def _without_new_instance_variables
        existing_instance_variables = instance_variables

        yield
      ensure
        (
          instance_variables -
          existing_instance_variables -
          ALLOWED_NEW_IVARS_DURING_RENDER
        ).each(&method(:remove_instance_variable))
      end
    end
  end
end
