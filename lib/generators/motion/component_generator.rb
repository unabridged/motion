# frozen_string_literal: true

require "rails/generators/named_base"

module Motion
  module Generators
    # This generator creates a Motion-enabled component in your application.
    # Currently, it only works with
    # {https://github.com/github/view_component Github's ViewComponent}. For
    # more information on the options that the generator supports, see
    # {https://github.com/github/view_component#quick-start their docs}.
    #
    #   $ bin/rails g motion:component PostComponent title content
    #
    # @api public
    class ComponentGenerator < Rails::Generators::NamedBase
      desc "Creates a Motion-enabled component in your application."

      argument :attributes, type: :array, default: [], banner: "attribute"

      # Invokes the underlying +ComponentGenerator+ with the provided attributes
      #
      # @return [void]
      # @api private
      def generate_component
        generate "component", class_name, *attributes.map(&:name)
      end

      # Mixes {Motion::Component} into the newly generated component
      #
      # @return [void]
      # @api private
      def include_motion
        inject_into_class component_path, "#{class_name}Component" do
          "  include Motion::Component\n\n"
        end
      end

      private

      def component_path
        @component_path ||=
          File.join("app/components", class_path, "#{file_name}_component.rb")
      end

      def file_name
        @_file_name ||= super.sub(/_component\z/i, "")
      end
    end
  end
end
