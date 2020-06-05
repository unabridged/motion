# frozen_string_literal: true

require 'motion/version'

module Motion
  class Error < StandardError; end

  autoload :Channel, 'motion/channel'
  autoload :Component, 'motion/component'
  autoload :Serializer, 'motion/serializer'

  class AlreadyInitializedError < Error
    def initialize(option)
      super(<<~MSG) # TODO: Better message (Focus on "How do I fix this?")
        Cannot set #{option} because Motion has already been used.
        This doesn't really make any sense.
        Make sure you are setting these values in an initializer.
      MSG
    end
  end

  class << self
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

    private

    def assert_uninitialized!(option)
      return unless defined?(@serializer)

      raise AlreadyInitializedError, option
    end

    def derive_secret_from_application
      require 'rails/application'
      Rails.application.key_generator.generate_key('motion:secret')
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
