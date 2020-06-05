# frozen_string_literal: true

require 'motion'

module Motion
  module Component
    module Rendering
      def render_in(view_context)
        raise BlockNotAllowedError, self if block_given?

        RenderContext.render_in(self, view_context) do
          without_new_instance_variables { super }
        end
      end

      private

      # TODO: Remove exactly the ivars added by ActionView (eg @view_context and friends)
      # and warn if we find any before rendering (ivars from the user which may clash with
      # ActionView)
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
