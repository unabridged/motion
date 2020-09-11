# frozen_string_literal: true

require "motion/version"
require "motion/errors"

module Motion
  autoload :ActionCableExtentions, "motion/action_cable_extentions"
  autoload :Callback, "motion/callback"
  autoload :Channel, "motion/channel"
  autoload :Component, "motion/component"
  autoload :ComponentConnection, "motion/component_connection"
  autoload :Configuration, "motion/configuration"
  autoload :Element, "motion/element"
  autoload :Event, "motion/event"
  autoload :LogHelper, "motion/log_helper"
  autoload :MarkupTransformer, "motion/markup_transformer"
  autoload :Railtie, "motion/railtie"
  autoload :RevisionCalculator, "motion/revision_calculator"
  autoload :Serializer, "motion/serializer"
  autoload :TestHelpers, "motion/test_helpers"

  class << self
    def configure(&block)
      raise AlreadyConfiguredError if @config

      @config = Configuration.new(&block)
    end

    def config
      @config ||= Configuration.default
    end

    alias_method :configuration, :config

    def serializer
      @serializer ||= Serializer.new
    end

    def markup_transformer
      @markup_transformer ||= MarkupTransformer.new
    end

    def build_renderer_for(websocket_connection)
      config.renderer_for_connection_proc.call(websocket_connection)
    end

    def notify_error(error, message)
      config.error_notification_proc&.call(error, message)
    end

    # This method only exists for testing. Changing configuration while Motion
    # is in use is not supported. It is only safe to call this method when no
    # components are currently mounted.
    def reset_internal_state_for_testing!(new_configuration = nil)
      @config = new_configuration
      @serializer = nil
      @markup_transformer = nil
    end
  end
end

require "motion/railtie" if defined?(Rails)
