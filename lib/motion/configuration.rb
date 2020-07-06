# frozen_string_literal: true

require "motion"

module Motion
  class Configuration
    class << self
      attr_reader :options

      def default
        @default ||= new
      end

      private

      attr_writer :options

      def option(option, &default)
        define_option_reader(option, &default)
        define_option_writer(option)

        self.options = [*options, option].freeze
      end

      def define_option_reader(option, &default)
        define_method(option) do
          if instance_variable_defined?(:"@#{option}")
            instance_variable_get(:"@#{option}")
          else
            instance_variable_set(:"@#{option}", instance_exec(&default))
          end
        end
      end

      def define_option_writer(option)
        define_method(:"#{option}=") do |value|
          raise AlreadyConfiguredError if @finalized

          instance_variable_set(:"@#{option}", value)
        end
      end
    end

    def initialize
      yield self if block_given?

      # Ensure a value is selected for all options
      self.class.options.each(&method(:public_send))

      # Prevent further changes
      @finalized = true
    end

    # //////////////////////////////////////////////////////////////////////////

    option :secret do
      require "rails"

      Rails.application.key_generator.generate_key("motion:secret")
    end

    option :revision_paths do
      require "rails"

      Rails.application.config.paths.dup.tap do |paths|
        paths.add "bin", glob: "*"
        paths.add "Gemfile.lock"
      end
    end

    option :revision do
      RevisionCalculator.new(revision_paths: revision_paths).perform
    end

    option :renderer_for_connection_proc do
      ->(websocket_connection) do
        require "rack"
        require "action_controller"

        # Make a special effort to use the host application's base controller
        # in case the CSRF protection has been customized, but don't couple to
        # a particular constant from the outer application.
        controller =
          if defined?(ApplicationController)
            ApplicationController
          else
            ActionController::Base
          end

        controller.renderer.new(
          websocket_connection.env.slice(
            Rack::HTTP_COOKIE,
            Rack::RACK_SESSION
          )
        )
      end
    end

    option(:key_attribute) { "data-motion-key" }
    option(:state_attribute) { "data-motion-state" }

    # This is included for completeness. It is not currently used internally by
    # Motion, but it might be required for building view helpers in the future.
    option(:motion_attribute) { "data-motion" }
  end
end
