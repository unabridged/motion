# frozen_string_literal: true

require "motion/version"
require "motion/errors"

module Motion
  autoload :Channel, "motion/channel"
  autoload :Component, "motion/component"
  autoload :Configuration, "motion/configuration"
  autoload :MarkupTransformer, "motion/markup_transformer"
  autoload :Serializer, "motion/serializer"
  autoload :TestHelpers, "motion/test_helpers"

  def self.configure(&block)
    raise AlreadyInitializedError, :configure if @config

    @config = Configuration.new(&block)
  end

  def self.config
    @config ||= Configuration.default
  end

  singleton_class.alias_method :configuration, :config

  def self.serializer
    @serializer ||= Serializer.new(secret: config.secret, revision: revision)
  end

  def self.markup_transformer
    @markup_transformer ||=
      MarkupTransformer.new(
        serializer: serializer,
        stimulus_controller_identifier: config.stimulus_controller_identifier,
        key_attribute: config.key_attribute,
        state_attribute: config.state_attribute
      )
  end

  def self.revision
    config.revision
  end

  def self.build_renderer_for(websocket_connection)
    config.renderer_for_connection_proc.call(websocket_connection)
  end
end
