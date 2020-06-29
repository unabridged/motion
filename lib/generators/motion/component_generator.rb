# frozen_string_literal: true

require "rails/generators/named_base"

module Motion
  module Generators
    class ComponentGenerator < Rails::Generators::NamedBase
      desc "Creates a Motion-enabled component in your application."

      argument :attributes, type: :array, default: [], banner: "attribute"

      def generate_component
        generate "component", class_name, *attributes.map(&:name)
      end

      def include_motion
        inject_into_class component_path, "#{class_name}Component" do
          "  include Motion::Component#{whitespace_after_include}"
        end
      end

      private

      def whitespace_after_include
        if attributes.any?
          "\n\n"
        else
          "\n"
        end
      end

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
