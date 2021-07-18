# frozen_string_literal: true

require "motion"

module Motion
  module Component
    module Rendering
      STATE_EXCLUDED_IVARS = %i[
        @_action_callback_context
        @_awaiting_forced_rerender
        @_routes

        @view_context
        @lookup_context
        @view_renderer
        @view_flow
        @virtual_path
        @variant
        @current_template
        @output_buffer

        @helpers
        @controller
        @request
        @tag_builder

        @asset_resolver_strategies
        @assets_environment
      ].freeze

      STATE_IVAR_OBFUSCATION_PREFIX = "@__vc_"

      private_constant :STATE_EXCLUDED_IVARS, :STATE_IVAR_OBFUSCATION_PREFIX

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

      def _clear_awaiting_forced_rerender!
        @_awaiting_forced_rerender = false
      end

      def marshal_dump
        (instance_variables - STATE_EXCLUDED_IVARS)
          .reject { |ivar| ivar.start_with? STATE_IVAR_OBFUSCATION_PREFIX }
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
