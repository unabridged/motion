# frozen_string_literal: true

require "motion"

module Motion
  module Component
    module Rendering
      def render_in(view_context)
        raise BlockNotAllowedError, self if block_given?

        html = view_context.capture { without_new_instance_variables { super } }

        Motion.markup_transformer.add_state_to_html(self, html)
      end

      private

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
