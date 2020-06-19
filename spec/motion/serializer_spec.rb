# frozen_string_literal: true

RSpec.describe Motion::Serializer do
  subject(:serializer) do
    described_class.new(
      secret: secret,
      revision: revision
    )
  end

  let(:secret) { SecureRandom.random_bytes(64) }
  let(:revision) { "revision-string" }

  context "when the secret is too short" do
    let(:secret) { SecureRandom.random_bytes(1) }

    it "raises BadSecretError" do
      expect { subject }.to raise_error(Motion::BadSecretError)
    end
  end

  context "when the revision contains a NULL byte" do
    let(:revision) { "hello\0world" }

    it "raises BadRevisionError" do
      expect { subject }.to raise_error(Motion::BadRevisionError)
    end
  end

  describe "#serialize" do
    subject(:output) { serializer.serialize(object) }

    let(:key) { output[0] }
    let(:state) { output[1] }

    context "when the object can be serialized" do
      let(:object) { [secret_data] }
      let(:secret_data) { SecureRandom.hex }

      it "does not give a key which reveals any internal information" do
        expect(key).not_to include(secret_data)
      end

      it "does not give state which reveals any internal information" do
        expect(state).not_to include(secret_data)
      end
    end

    context "when the object cannot be serialized" do
      let(:object) { Class.new.new }

      it "raises Motion::UnrepresentableStateError" do
        expect { subject }.to raise_error(Motion::UnrepresentableStateError)
      end
    end
  end

  describe "#deserialize" do
    subject { serializer.deserialize(state) }

    context "with invalid state" do
      let(:state) { SecureRandom.hex }

      it "raises InvalidSerializedStateError" do
        expect { subject }.to raise_error(Motion::InvalidSerializedStateError)
      end
    end

    context "with valid state" do
      let(:state) do
        _key, state = serializer.serialize(object)
        state
      end

      let(:object) { [SecureRandom.hex] }

      it "deserializes the object" do
        expect(subject).to eq(object)
      end
    end

    context "with state that needs to be upgraded" do
      let(:state) do
        _key, state = serializer_for_previous_revision.serialize(object)
        state
      end

      let(:object) { Object.new }
      let(:upgraded_object) { Object.new }

      let(:serializer_for_previous_revision) do
        described_class.new(secret: secret, revision: previous_revision)
      end

      let(:previous_revision) { "a-revision-before-#{revision}" }

      it "tries to upgrade the component" do
        expect(object.class).to(
          receive(:upgrade_from)
          .with(previous_revision, object.class)
          .and_return(upgraded_object)
        )

        expect(subject).to be(upgraded_object)
      end
    end
  end
end
