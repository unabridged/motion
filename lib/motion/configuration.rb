# frozen_string_literal: true

require "motion"

module Motion
  class Configuration
    JS_CONSTANTS = JSON.parse(File.read(File.expand_path(
      "../../javascript/constants.json", __dir__
    ))).freeze

    private_constant :JS_CONSTANTS

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
        define_method(:"#{option}=") do |option|
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
        If it does, put "Motion.revision = `git rev-parse HEAD`.chomp" in your
        initializer. If it does not, do something else (probably read an env
        var or something).
      MSG

      `git rev-parse HEAD`.chomp
    end

    option :renderer do
      require "rails"

      begin
        ApplicationController.renderer
      rescue NameError
        ActionController::Base.renderer
      end
    end

    option :renderer_for_connection_proc do
      require "rack"

      ->(connection) do
        renderer.new(
          connection.env.slice(
            Rack::HTTP_COOKIE,
            Rack::RACK_SESSION,
            Rack::RACK_SESSION_OPTIONS,
            Rack::RACK_SESSION_UNPACKED_COOKIE_DATA
          )
        )
      end
    end

    option(:stimulus_controller_identifier) { "motion" }
    option(:key_attribute) { JS_CONSTANTS.fetch("keyAttr") }
    option(:state_attribute) { JS_CONSTANTS.fetch("stateAttr") }
  end
end
