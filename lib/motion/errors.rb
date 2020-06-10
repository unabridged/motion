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

    def component_class
      component.class.to_s
    end
  end

  class ComponentRenderingError < ComponentError; end

  class ActionNotMapped < ComponentError
    attr_reader :action

    def initialize(component, action)
      super(<<~MSG)
        No component action handler mapped for action '#{action}' in component #{component_class}.

        Fix: Add the following to #{component_class}:

        map_action :#{action}
      MSG

      @action = action
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
        The template for #{component_class} can only have one root element.

        Fix: Wrap all elements in a single element, such as <div> or <section>.
      MSG
    end
  end

  class InvalidComponentStateError < ComponentError; end

  class UnrepresentableStateError < InvalidComponentStateError
    def initialize(component, cause)
      super(component, <<~MSG)
        Some state prevented #{component_class} from being serialized into a
        string. Motion components must be serializable using Marshal.dump. Many
        types of objects are not serializable including procs, references to
        anonymous classes, and more. See the documentation for Marshal.dump for
        more information.

        Fix: Ensure that any exotic state variables in #{component_class} are
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

  class AlreadyInitializedError < Error
    def initialize(option)
      super(<<~MSG)
        Cannot set #{option} because Motion is already initialized.

        Fix: Move all Motion config to config/initializers/motion.rb.
      MSG
    end
  end
end
