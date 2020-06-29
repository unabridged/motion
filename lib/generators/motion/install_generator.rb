# frozen_string_literal: true

require "rails/generators/base"

module Motion
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Installs Motion into your application."

      def copy_initializer
        template(
          "motion.rb",
          "config/initializers/motion.rb"
        )
      end

      def copy_client_initializer
        template(
          "motion.js",
          "app/javascript/motion.js"
        )
      end

      def add_client_to_application_pack
        append_to_file(
          "app/javascript/packs/application.js",
          'import "motion"'
        )
      end
    end
  end
end
