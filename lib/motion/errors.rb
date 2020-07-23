# frozen_string_literal: true

require "motion"

module Motion
  # Sometimes things don't go the way we had hoped. This module contains all of
  # the errors that can occur while using Motion.
  #
  # All errors descend from descend from {Motion::Errors::Error}.
  module Errors
    # This is the base error in Motion. All that can occur while using Motion
    # descend from this class.
    #
    # @note
    #   This error should never be raised directly. Instead, a more specific
    #   subclass with contextual information should always be preferred.
    class Error < StandardError; end

    # This is the base class for all errors involving a specific component
    # instance in Motion.
    #
    # @note
    #   This error should never be raised directly. Instead, a more specific
    #   subclass with contextual information should always be preferred.
    class ComponentError < Error
      # @return [Motion::Component] the component on which the error occurred
      attr_reader :component

      # @param component [Motion::Component]
      #   the component on which the error occurred
      # @param message [String] additional information about the error
      #
      # @api private
      def initialize(component, message = nil)
        super(message)

        @component = component
      end
    end

    # This is the base class for all errors that can occur while rendering a
    # component in Motion.
    #
    # @note
    #   This error should never be raised directly. Instead, a more specific
    #   subclass with contextual information should always be preferred.
    class ComponentRenderingError < ComponentError; end

    # This error is raised when the client attempts to run a motion that
    # the component has not mapped. See
    # {Motion::Component::Motions::ModuleFunctions#map_motion} for details.
    class MotionNotMappedError < ComponentError
      # @return [String] the motion that is not mapped
      attr_reader :motion

      # @param component [Motion::Component]
      #   the component on which the error occurred
      # @param motion [String] the motion that is not mapped
      #
      # @api private
      def initialize(component, motion)
        super(
          component,
          "No component motion handler mapped for motion `#{motion}` in " \
          "component `#{component.class}`.\n" \
          "\n" \
          "Hint: Consider adding `map_motion :#{motion}` to " \
          "`#{component.class}`."
        )

        @motion = motion
      end
    end

    # This error is raised when a component is rendered with a block. Motion
    # does not support rendering components with a block.
    class BlockNotAllowedError < ComponentRenderingError
      # @param component [Motion::Component]
      #   the component on which the error occurred
      #
      # @api private
      def initialize(component)
        super(
          component,
          "Motion does not support rendering with a block.\n" \
          "\n" \
          "Hint: Try wrapping a plain component with a motion component."
        )
      end
    end

    # This error is raised when a component's template does not contain exactly
    # one root element.
    class MultipleRootsError < ComponentRenderingError
      # @param component [Motion::Component]
      #   the component on which the error occurred
      #
      # @api private
      def initialize(component)
        super(
          component,
          "The template for #{component.class} can only have one root " \
          "element.\n" \
          "\n" \
          "Hint: Wrap all elements in a single element, such as `<div>` or " \
          "`<section>`."
        )
      end
    end

    # This error is raised when a component halts the callbacks during a render.
    class RenderAborted < ComponentRenderingError
      # @param component [Motion::Component]
      #   the component on which the error occurred
      #
      # @api private
      def initialize(component)
        super(component, <<~MSG)
          Rendering #{component.class} was aborted by a callback.
        MSG
      end
    end

    # This is the base class for all errors that can occur while serializing a
    # component in Motion.
    #
    # @note
    #   This error should never be raised directly. Instead, a more specific
    #   subclass with contextual information should always be preferred.
    class InvalidComponentStateError < ComponentError; end

    # This error is raised when a component has state which cannot be serialized
    # by +Marshal+.
    class UnrepresentableStateError < InvalidComponentStateError
      # @param component [Motion::Component]
      #   the component on which the error occurred
      # @param cause [String]
      #   the message from +Marshal+
      #
      # @api private
      def initialize(component, cause)
        super(
          component,
          "Some state prevented `#{component.class}` from being serialized " \
          "into a string. Motion components must be serializable using " \
          "`Marshal.dump`. Many types of objects are not serializable " \
          "including procs, references to anonymous classes, and more. See " \
          "the documentation for `Marshal.dump` for more information.\n" \
          "\n" \
          "The specific error from `Marshal.dump` was: #{cause}\n" \
          "\n" \
          "Hint: Ensure that any exotic state variables in " \
          "`#{component.class}` are removed or replaced."
        )
      end
    end

    # This is the base class for all errors that can occur while deserializing a
    # component in Motion.
    #
    # @note
    #   This error should never be raised directly. Instead, a more specific
    #   subclass with contextual information should always be preferred.
    class SerializedComponentError < Error; end

    # This error is raised when the serialized state of a component is not
    # valid.
    class InvalidSerializedStateError < SerializedComponentError
      # @api private
      def initialize
        super(
          "The serialized state of your component is not valid.\n" \
          "\n" \
          "Hint: Ensure that you have not tampered with the contents of data " \
          "attributes added by Motion in the DOM or changed the value of " \
          "`Motion.config.secret`."
        )
      end
    end

    # This error is raised when a componet from another revision of the
    # application is mounted without an implemention for
    # {Motion::Component::Lifecycle::ClassMethods#upgrade_from}.
    class UpgradeNotImplementedError < ComponentError
      # @return [String]
      #   the previous revision of the application (see
      #   {Motion::Configuration#revision})
      attr_reader :previous_revision

      # @return [String]
      #   the current revision of the application (see
      #   {Motion::Configuration#revision})
      attr_reader :current_revision

      # @param component [Motion::Component]
      #   the component on which the error occurred
      # @param previous_revision [String]
      #   the previous revision of the application (see
      #   {Motion::Configuration#revision})
      # @param current_revision [String]
      #   the current revision of the application (see
      #   {Motion::Configuration#revision})
      #
      # @api private
      def initialize(component, previous_revision, current_revision)
        super(
          component,
          "Cannot upgrade `#{component.class}` from a previous revision of " \
          "the application (#{previous_revision}) to the current revision of " \
          "the application (#{current_revision})\n" \
          "\n" \
          "By default, Motion does not allow components from other revisions " \
          "of the application to be mounted because new code with old state " \
          "can lead to unpredictable and unsafe behavior.\n" \
          "\n" \
          "Hint: If you would like to allow this component to surive " \
          "deployments, consider providing an alternative implimentation for " \
          "`#{component.class}.upgrade_from`."
        )

        @previous_revision = previous_revision
        @current_revision = current_revision
      end
    end

    # This error is raised when a configuration option is changed after Motion
    # has already been initialized. See {Motion::Configuration} for details.
    class AlreadyConfiguredError < Error
      # @api private
      def initialize
        super(
          "Motion is already configured.\n" \
          "\n" \
          "Hint: Move all Motion config to `config/initializers/motion.rb`."
        )
      end
    end

    # This error is raised when a client that is not supported by the server
    # attempts to mount a component. There is no way for Motion to recover
    # under this circumstance.
    class IncompatibleClientError < Error
      # @return [String] the unsupported client version
      attr_reader :client_version

      # @param client_version [String] the unsupported client version
      #
      # @api private
      def initialize(client_version)
        super(
          "The client version (#{client_version}) is newer than the server " \
          "version (#{Motion::VERSION}). Please upgrade the Motion gem.\n" \
          "\n" \
          "Hint: Run `bundle add motion --version \">= #{client_version}\"`."
        )

        @client_version = client_version
      end
    end

    # This error is raised when a secret that is too short is supplied.
    class BadSecretError < Error
      # @return [Integer] the minimum number of bytes that the secret must have
      attr_reader :minimum_bytes

      # @param minimum_bytes [Integer] the minimum number of bytes
      #
      # @api private
      def initialize(minimum_bytes)
        super(
          "The secret that you provided is not long enough. It must be at " \
          "least #{minimum_bytes} bytes long."
        )
      end
    end

    # This error is raised when a revision containing a NULL byte is supplied.
    class BadRevisionError < Error
      # @api private
      def initialize
        super("The revision cannot contain a NULL byte.")
      end
    end

    # This error is raised when an invalid revision path is specified.
    class BadRevisionPathsError < Error
      # @api private
      def initialize
        super(
          "Revision paths must be a `Rails::Paths::Root` object or an object " \
          "that responds to `all_paths.flat_map(&:existent)` and returns an " \
          "Array of strings representing full paths."
        )
      end
    end
  end
end
