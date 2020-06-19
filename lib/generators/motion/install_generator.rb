# frozen_string_literal: true

require "rails/generators/base"

module Generators
  module Motion
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Installs Motion into your application."

      def copy_initializer
        template(
          "motion.rb",
          "config/initializers/motion.rb"
        )
      end

      def copy_stimlus_controller
        template(
          "motion_controller.js",
          "app/javascript/controllers/motion_controller.js"
        )
      end
    end
  end
end
