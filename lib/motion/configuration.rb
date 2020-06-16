# frozen_string_literal: true

require "motion"

module Motion
  class Configuration
    class << self
      attr_reader :options

      def default
        new
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

    option :revision do
      warn <<~MSG # TODO: Better message (Focus on "How do I fix this?")
        Motion is automatically inferring the application's revision from git.
        Depending on your deployment, this may not work for you in production.
        If it does, add "config.revision = `git rev-parse HEAD`.chomp" to your
        Motion initializer. If it does not, do something else (probably read an
        env var or something).
      MSG

      `git rev-parse HEAD`.chomp
    end

    option :renderer_for_connection_proc do
      require "rack"

      ->(websocket_connection) do
        ApplicationController.renderer.new(
          websocket_connection.env.slice(
            Rack::HTTP_COOKIE,
            Rack::RACK_SESSION
          )
        )
      end
    end

    option(:stimulus_controller_identifier) { "motion" }
    option(:key_attribute) { "data-motion-key" }
    option(:state_attribute) { "data-motion-state" }

    # This is included for completeness. It is not currently used internally by
    # Motion, but it might be required for building view helpers in the future.
    option(:motion_attribute) { "data-motion" }
  end
end
