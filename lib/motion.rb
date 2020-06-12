# frozen_string_literal: true

require "motion/version"
require "motion/errors"

module Motion
  autoload :Channel, "motion/channel"
  autoload :Component, "motion/component"
  autoload :MarkupTransformer, "motion/markup_transformer"
  autoload :Serializer, "motion/serializer"
  autoload :TestHelpers, "motion/test_helpers"

  # TODO: Move configuration options into configuration class.
  class << self
    def markup_transformer
      @markup_transformer ||= MarkupTransformer.new(serializer: serializer)
    end

    def serializer
      @serializer ||= Serializer.new(secret: secret, revision: revision)
    end

    def secret=(secret)
      assert_uninitialized!(:secret)
      @secret = secret
    end

    def secret
      @secret ||= derive_secret_from_application
    end

    def revision=(revision)
      assert_uninitialized!(:revision)
      @revision = revision
    end

    def revision
      @revision ||= revision_from_git_fallback
    end

    attr_writer :renderer

    def renderer
      @renderer ||= ApplicationController.renderer
    end

    # TODO: Where does this go?
    def build_renderer_for(websocket_connection)
      renderer.new(
        websocket_connection.env.slice(
          Rack::HTTP_COOKIE,
          Rack::RACK_SESSION,
          Rack::RACK_SESSION_OPTIONS,
          Rack::RACK_SESSION_UNPACKED_COOKIE_DATA
        )
      )
    end

    private

    def assert_uninitialized!(option)
      return unless defined?(@serializer)

      raise Errors::AlreadyInitializedError, option
    end

    def derive_secret_from_application
      require "rails/application"
      Rails.application.key_generator.generate_key("motion:secret")
    end

    def revision_from_git_fallback
      warn <<~MSG # TODO: Better message (Focus on "How do I fix this?")
        Motion is automatically inferring the application's revision from git.
        Depending on your deployment, this may not work for you in production.
        If it does, put "Motion.revision = `git rev-parse HEAD`.chomp" in your
        initializer. If it does not, do something else (probably read an env
        var or something).
      MSG

      `git rev-parse HEAD`.chomp
    end
  end
end
