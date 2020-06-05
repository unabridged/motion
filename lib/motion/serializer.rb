# frozen_string_literal: true

require 'digest'
require 'active_support/message_encryptor'

require 'motion'

module Motion
  class Serializer
    HASH_PEPPER = 'Motion'
    private_constant :HASH_PEPPER

    attr_reader :secret, :revision

    def initialize(secret:, revision:)
      @secret = secret
      @revision = revision
    end

    def serialize(component)
      state = dump(component)
      state_with_revision = "#{revision},#{state}"

      assert_no_nested_components_in_state!(component, state)

      [
        salted_digest(state_with_revision),
        encryptor.encrypt_and_sign(state_with_revision)
      ]
    end

    def deserialize(serialized_component)
      state_with_revision = decrypt_and_verify(serialized_component)
      actual_revision, state = state_with_revision.split(',', 2)

      assert_correct_revision!(actual_revision)

      load(state)
    end

    private

    def assert_no_nested_components_in_state!(component, state)
      seen_component = false

      load(state, proc { |object|
        object.tap do
          next unless object.is_a?(Component)
          raise NestedComponentInStateError, component if seen_component

          seen_component = true
        end
      })

      nil
    end

    def assert_correct_revision!(actual_revision)
      return if actual_revision == revision

      raise IncorrectRevisionError.new(revision, actual_revision)
    end

    def dump(component)
      Marshal.dump(component)
    rescue TypeError => e
      raise UnrepresentableStateError.new(component, e.message)
    end

    def load(state, *args)
      Marshal.load(state, *args)
    end

    def encrypt_and_sign(cleartext)
      encryptor.encrypt_and_sign(cleartext)
    end

    def decrypt_and_verify(cypertext)
      encryptor.decrypt_and_verify(cypertext)
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      raise InvalidSerializedStateError
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
