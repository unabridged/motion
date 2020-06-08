# frozen_string_literal: true

require 'motion'

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

  class ActionNotMapped < ComponentError
    attr_reader :action

    def initialize(component, action)
      super(<<~MSG)
        No component action handler mapped for action '#{action}' in component #{component.class}.
      MSG

      @action = action
    end
  end

  class BlockNotAllowedError < ComponentRenderingError
    def initialize(component)
      super(component, <<~MSG) # TODO: Better message (Focus on "How do I fix this?")
        Rendering with a block is not supported with motion.

        Hint: Use a plain component instead and wrap with a motion component.
      MSG
    end
  end

  class MultipleRootsError < ComponentRenderingError
    def initialize(component)
      super(component, <<~MSG) # TODO: Better message (Focus on "How do I fix this?")
        You can only have one root element in your component.
      MSG
    end
  end

  class InvalidComponentStateError < ComponentError; end

  class UnrepresentableStateError < InvalidComponentStateError
    def initialize(component, cause)
      super(component, <<~MSG) # TODO: Better message (Focus on "How do I fix this?")
        Something about your component cannot be serialized into a string. Make sure it doesn't
        have anything exotic in its state (i.e. a proc, a reference to an anonymous class, etc).

        The specific (but probably useless) error from Marshal was: #{cause}
      MSG
    end
  end

  class NestedComponentInStateError < InvalidComponentStateError
    def initialize(component)
      super(component, <<~MSG) # TODO: Better message (Focus on "How do I fix this?")
        Detected nested component in state.

        Fundamentally, components live in the DOM. The component instance that you have is
        a template for what to render, **NOT** a handle to the actual rendered component
        (To get an intuition for why it works this way, consider what would happen if
        you rendered a component in a broadcast and sent the resulting markup to many clients.
        Which of those clients instances should this handle refer to? What if no one ever
        renders the markup?).

        In theory, it is technically fine to build up these templates over time and store
        them in your state, but that is almost certainly not what you are expecting here.
        Chances are, you have already rendered this template once and now you are want
        this instance to allow you to access that rendered component. This won't work.

        Alternatives:
          * To communicate from parent to child, pass information into the component before rendering.
          * To communicate from child to parent, use global mutable state (your database) or broadcasts.
      MSG
    end
  end

  class SerializedComponentError < Error; end

  class InvalidSerializedStateError < SerializedComponentError
    def initialize
      super(<<~MSG) # TODO: Better message (Focus on "How do I fix this?")
        The serialized state of your component is not valid. Did someone tamper with it in the DOM?
      MSG
    end
  end

  class IncorrectRevisionError < SerializedComponentError
    attr_reader :expected_revision,
                :actual_revision

    def initialize(expected_revision, actual_revision)
      super(<<~MSG) # TODO: Better message (Focus on "How do I fix this?")
        Cannot mount a component from another version of the application.

        Expected revision `#{expected_revision}`;
        Got `#{actual_revision}`
      MSG

      @expected_revision = expected_revision
      @actual_revision = actual_revision
    end
  end

  class AlreadyInitializedError < Error
    def initialize(option)
      super(<<~MSG) # TODO: Better message (Focus on "How do I fix this?")
        Cannot set #{option} because Motion has already been used.
        This doesn't really make any sense.
        Make sure you are setting these values in an initializer.
      MSG
    end
  end
end
