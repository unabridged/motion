# frozen_string_literal: true

require "rails/generators/base"

module Motion
  module Generators
    # This generator installs Motion into a new Rails project. It creates
    # initializers for the gem and client, and imports the client into the
    # application bundle. For most projects, the defaults should be
    # sufficent; however, you can see a list of the full options for the gem
    # in {Motion::Configuration}.
    #
    #   $ bin/rails g motion:install
    #
    # @api public
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Installs Motion into your application."

      # Copies the default initializer for the gem into the application
      #
      # @return [void]
      # @api private
      def copy_initializer
        template(
          "motion.rb",
          "config/initializers/motion.rb"
        )
      end

      # Copies the default initializer for the client into the application
      #
      # @return [void]
      # @api private
      def copy_client_initializer
        template(
          "motion.js",
          "app/javascript/motion.js"
        )
      end

      # Imports Motion into the application JavaScript bundle
      #
      # @return [void]
      # @api private
      def add_client_to_application_pack
        append_to_file(
          "app/javascript/packs/application.js",
          'import "motion"'
        )
      end
    end
  end
end
