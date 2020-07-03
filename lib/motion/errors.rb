# frozen_string_literal: true

require "motion"

module Motion
  class Error < StandardError; end

  class ComponentError < Error
    attr_reader :component

    def initialize(component, message = nil)
      super(message)
      @component = component
    end
  end

  class ComponentRenderingError < ComponentError; end

  class MotionNotMapped < ComponentError
    attr_reader :motion

    def initialize(component, motion)
      super(component, <<~MSG)
        No component motion handler mapped for motion '#{motion}' in component #{component.class}.

        Fix: Add the following to #{component.class}:

        map_motion :#{motion}
      MSG

      @motion = motion
    end
  end

  class BlockNotAllowedError < ComponentRenderingError
    def initialize(component)
      super(component, <<~MSG)
        Motion does not support rendering with a block.

        Fix: Use a plain component and wrap with a motion component.
      MSG
    end
  end

  class MultipleRootsError < ComponentRenderingError
    def initialize(component)
      super(component, <<~MSG)
        The template for #{component.class} can only have one root element.

        Fix: Wrap all elements in a single element, such as <div> or <section>.
      MSG
    end
  end

  class InvalidComponentStateError < ComponentError; end

  class UnrepresentableStateError < InvalidComponentStateError
    def initialize(component, cause)
      super(component, <<~MSG)
        Some state prevented #{component.class} from being serialized into a
        string. Motion components must be serializable using Marshal.dump. Many
        types of objects are not serializable including procs, references to
        anonymous classes, and more. See the documentation for Marshal.dump for
        more information.

        Fix: Ensure that any exotic state variables in #{component.class} are
        removed or replaced.

        The specific (but probably useless) error from Marshal was: #{cause}
      MSG
    end
  end

  class SerializedComponentError < Error; end

  class InvalidSerializedStateError < SerializedComponentError
    def initialize
      super(<<~MSG)
        The serialized state of your component is not valid.

        Fix: Ensure that you have not tampered with the DOM.
      MSG
    end
  end

  class IncorrectRevisionError < SerializedComponentError
    attr_reader :expected_revision,
      :actual_revision

    def initialize(expected_revision, actual_revision)
      super(<<~MSG)
        Cannot mount a component from another version of the application.

        Expected revision `#{expected_revision}`;
        Got `#{actual_revision}`

        Read more: https://github.com/unabridged/motion/wiki/IncorrectRevisionError

        Fix:
          * Avoid tampering with Motion DOM elements and data attributes (e.g. data-motion-state).
          * In production, enforce a page refresh for pages with Motion components on deploy.
      MSG

      @expected_revision = expected_revision
      @actual_revision = actual_revision
    end
  end

  class AlreadyConfiguredError < Error
    def initialize
      super(<<~MSG)
        Motion is already configured.

        Fix: Move all Motion config to config/initializers/motion.rb.
      MSG
    end
  end

  class IncompatibleClientError < Error
    attr_reader :server_version, :client_version

    def initialize(server_version, client_version)
      super(<<~MSG)
        The client version (#{client_version}) is newer than the server version
        (#{server_version}). Please upgrade the Motion gem.

        Fix: Run `bundle update motion`
      MSG

      @server_version = server_version
      @client_version = client_version
    end
  end

  class BadSecretError < Error
    attr_reader :minimum_bytes

    def initialize(minimum_bytes)
      super(<<~MSG)
        The secret that you provided is not long enough. It must have at least
        #{minimum_bytes} bytes.
      MSG
    end
  end

  class BadRevisionError < Error
    def initialize
      super("The revision cannot contain a NULL byte")
    end
  end

  class BadRevisionPathsError < Error
    def initialize
      super(<<~MSG)
        Revision paths must be a Rails::Paths::Root object or an object
        that responds to `all_paths.flat_map(&:existent)` and returns an
        Array of strings representing paths relative to root.
      MSG
    end
  end
end
