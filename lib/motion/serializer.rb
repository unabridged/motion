# frozen_string_literal: true

require "digest"
require "active_support/message_encryptor"

require "motion"

module Motion
  class Serializer
    HASH_PEPPER = "Motion"
    private_constant :HASH_PEPPER

    attr_reader :secret, :revision

    def initialize(secret:, revision:)
      @secret = secret
      @revision = revision
    end

    def serialize(component)
      state = dump(component)
      state_with_revision = "#{revision},#{state}"

      [
        salted_digest(state_with_revision),
        encryptor.encrypt_and_sign(state_with_revision)
      ]
    end

    def deserialize(serialized_component)
      state_with_revision = decrypt_and_verify(serialized_component)
      serialized_revision, state = state_with_revision.split(",", 2)
      component = load(state)

      if revision == serialized_revision
        component
      else
        component.class.upgrade_from(serialized_revision, component)
      end
    end

    private

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
