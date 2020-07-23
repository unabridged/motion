# frozen_string_literal: true

require "motion/version"

# Motion allows you to build reactive, real-time frontend UI components in your
# Rails application using pure Ruby. It has
# {https://www.npmjs.com/package/@unabridged/motion a companion NPM package}
# that should also be installed and requires
# {https://guides.rubyonrails.org/action_cable_overview.html ActionCable}.
#
# Users of this library are expected to configure it with {Motion.configure},
# and impliment components with {Motion::Component}. These components should
# also conform to
# {https://github.com/rails/rails/pull/36388 the Rails +render_in+ interface}.
#
# To help with setup,
# {Motion::Generators::InstallGenerator an install generator} is provided. The
# defaults should be acceptable for most projects. If you are using
# {https://github.com/github/view_component Github's ViewComponent},
# {Motion::Generators::ComponentGenerator a component generator} is also
# available.
module Motion
  autoload :ActionCableExtentions, "motion/action_cable_extentions"
  autoload :Callback, "motion/callback"
  autoload :Channel, "motion/channel"
  autoload :Component, "motion/component"
  autoload :ComponentConnection, "motion/component_connection"
  autoload :Configuration, "motion/configuration"
  autoload :Element, "motion/element"
  autoload :Errors, "motion/errors"
  autoload :Event, "motion/event"
  autoload :LogHelper, "motion/log_helper"
  autoload :MarkupTransformer, "motion/markup_transformer"
  autoload :Railtie, "motion/railtie"
  autoload :RevisionCalculator, "motion/revision_calculator"
  autoload :Serializer, "motion/serializer"
  autoload :TestHelpers, "motion/test_helpers"

  class << self
    # Configures Motion using the provided block. See {Configuration} for a
    # description of all of the options.
    #
    # @yield [configuration]
    # @yieldparam configuration [Configuration]
    #
    # @raise [Motion::Errors::AlreadyConfiguredError]
    #   This method can only be called when Motion is unconfigured.
    #
    # @return [void]
    def configure(&block)
      raise Errors::AlreadyConfiguredError if @config

      @config = Configuration.new(&block)
    end

    # Gives Motion's current configuration. See {Motion.configure} for details.
    #
    # @return [Configuration] the current {Configuration}
    def config
      @config ||= Configuration.default
    end

    alias configuration config

    # @return [Serializer] the {Serializer} that Motion will use
    # @api private
    def serializer
      @serializer ||= Serializer.new
    end

    # @return [MarkupTransformer] the {MarkupTransformer} that Motion will use
    # @api private
    def markup_transformer
      @markup_transformer ||= MarkupTransformer.new
    end

    # Gives the renderer to be used for a websocket connection. This will be
    # used by Motion to render components in the connection and affects what
    # helpers and enviorment are available.
    #
    # @param websocket_connection [ApplicationCable::Connection]
    # @return [ActionController::Renderer]
    # @api private
    def build_renderer_for(websocket_connection)
      config.renderer_for_connection_proc.call(websocket_connection)
    end

    # Notify the user-provided proc that an error occured within Motion.
    #
    # @api private
    # @param error [Exception] the error to be delivered
    # @param message [String] a message to give context for the error
    # @return [void]
    def notify_error(error, message)
      config.error_notification_proc&.call(error, message)
    end

    # Checks compatiblity with a version of the client.
    #
    # @api private
    # @return [Boolean] whether the client version is compatible
    def compatible_client_version?(client_version)
      (Gem::Version.new(MINIMUM_CLIENT_VERSION)..Gem::Version.new(VERSION))
        .cover?(Gem::Version.new(client_version))
    end

    # Resets or changes the configuration of Motion after it has already been
    # configured *given that no components are currently mounted*.
    #
    # @note This method only exists for testing.
    # @note This method is only safe to call when no components are mounted.
    # @api private
    # @param new_configuration [optional, Configuration] the new configuration
    # @return [void]
    def reset_internal_state_for_testing!(new_configuration = nil)
      @config = new_configuration
      @serializer = nil
      @markup_transformer = nil
    end
  end
end

require "motion/railtie" if defined?(Rails)
