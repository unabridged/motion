# frozen_string_literal: true

require 'digest'
require 'active_support/message_encryptor'

require 'motion'

module Motion
  class Serializer
    class InvalidStateError < Motion::Error
      attr_reader :component

      def initialize(component, message = nil)
        super(message)
        @component = component
      end
    end

    class UnrepresentableStateError < InvalidStateError
      def initialize(component, cause)
        super(component, <<~MSG) # TODO: Better message (Focus on "How do I fix this?")
          Something about your component cannot be serialized into a string. Make sure it doesn't
          have anything exotic in its state (i.e. a proc, a reference to an anonymous class, etc).

          The specific (but probably useless) error from Marshal was: #{cause}
        MSG
      end
    end

    class NestedComponentInStateError < InvalidStateError
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

    class InvalidSerializedStateError < Motion::Error
      def initialize
        super(<<~MSG) # TODO: Better message (Focus on "How do I fix this?")
          The serialized state of your component is not valid. Did someone tamper with it in the DOM?
        MSG
      end
    end

    class IncorrectRevisionError < Motion::Error
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

    HASH_PEPPER = 'Motion'
    private_constant :HASH_PEPPER

    attr_reader :secret, :revision

    def initialize(secret:, revision:)
      @secret = secret
      @revision = revision
    end

    def serialize(component)
      assert_no_nested_components_in_state!(component)

      state = dump(component)
      state_with_revision = "#{revision},#{state}"

      [
        salted_digest(state_with_revision),
        encryptor.encrypt_and_sign(state_with_revision)
      ]
    end

    def deserialize(serialized_component)
      state_with_revision = decrypt_and_verify(serialized_component)
      actual_revision, state = state_with_revision.split(',', 2)

      raise IncorrectRevisionError.new(revision, actual_revision) unless actual_revision == revision

      load(state)
    end

    private

    def assert_no_nested_components_in_state!(component)
      return unless nested_components_in_state?(component)

      raise NestedComponentInStateError, component
    end

    def dump(component)
      Marshal.dump(component)
    rescue TypeError => e
      raise UnrepresentableStateError.new(component, e.message)
    end

    def load(state)
      Marshal.load(state)
    end

    def encrypt_and_sign(cleartext)
      encryptor.encrypt_and_sign(cleartext)
    end

    def decrypt_and_verify(cypertext)
      encryptor.decrypt_and_verify(cypertext)
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      raise InvalidSerializedStateError
    end

    # TODO: This is just a heuristic. We could do this perfectly though by overriding #_dump_state
    # and "passing an implicit argument" via a thread global that we set to the root while marshaling.
    # Maybe the additional complexity it isn't worth it.
    def nested_components_in_state?(component)
      component.instance_variables.any? do |ivar|
        component.instance_variable_get(ivar).is_a?(Motion::Component)
      end
    end

    def salted_digest(input)
      Digest::SHA256.base64digest(hash_salt + input)
    end

    def encryptor
      @encryptor ||= ActiveSupport::MessageEncryptor.new(derive_encryptor_key)
    end

    def hash_salt
      @hash_salt ||= derive_hash_salt
    end

    def derive_encryptor_key
      secret.byteslice(0, ActiveSupport::MessageEncryptor.key_len)
    end

    def derive_hash_salt
      Digest::SHA256.digest(HASH_PEPPER + secret)
    end
  end
end
