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
        # TODO: This implementation is trivially correct, but very wasteful.
        #
        # Is something with Ruby's built-in `hash` Good Enough(TM)?
        #
        #  instance_variables
        #    .map { |ivar| instance_variable_get(ivar).hash }
        #    .reduce(0, &:^)

        key, _state = Motion.serializer.serialize(self)
        key
      end

      def render_in(view_context)
        raise BlockNotAllowedError, self if block_given?
        clear_awaiting_forced_rerender!

        html = view_context.capture { without_new_instance_variables { super } }

        Motion.markup_transformer.add_state_to_html(self, html)
      end

      private

      def clear_awaiting_forced_rerender!
        return unless awaiting_forced_rerender?

        remove_instance_variable(RERENDER_MARKER_IVAR)
      end

      # TODO: Remove exactly the ivars added by ActionView
      def without_new_instance_variables
        existing_instance_variables = instance_variables

        yield
      ensure
        (instance_variables - existing_instance_variables)
          .each(&method(:remove_instance_variable))
      end
    end
  end
end
