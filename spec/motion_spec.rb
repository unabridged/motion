# frozen_string_literal: true

RSpec.describe Motion do
  it "has a version number" do
    expect(Motion::VERSION).not_to be nil
  end

  describe ".configure", unconfigured: true do
    subject do
      @configure_block_called = false

      described_class.configure do |_config|
        @configure_block_called = true
      end
    end

    context "when Motion has not yet been configured" do
      it "creates a configuration using the block" do
        expect { subject }.not_to raise_error
        expect(@configure_block_called).to be true
      end
    end

    context "when Motion has already been configured" do
      before(:each) { Motion.configure {} }

      it "raises an error and does not call the block" do
        expect { subject }.to(
          raise_error(Motion::Errors::AlreadyConfiguredError)
        )

        expect(@configure_block_called).to be false
      end
    end
  end

  describe ".config", unconfigured: true do
    subject { described_class.config }

    context "when Motion has already been configured" do
      before(:each) do
        Motion.configure do |config|
          @configuration_from_configure_call = config
        end
      end

      it { is_expected.to be_a(Motion::Configuration) }

      it "gives the current configuration" do
        expect(subject).to be(@configuration_from_configure_call)
      end
    end

    context "when Motion has not yet been configured" do
      it "automatically uses the default configuration" do
        expect(subject).to be(Motion::Configuration.default)
      end
    end
  end

  describe ".serializer" do
    subject { described_class.serializer }

    it { is_expected.to be_a(Motion::Serializer) }
  end

  describe ".markup_transformer" do
    subject { described_class.markup_transformer }

    it { is_expected.to be_a(Motion::MarkupTransformer) }
  end

  describe ".build_renderer_for", unconfigured: true do
    subject { described_class.build_renderer_for(connection) }

    let(:connection) { double }
    let(:renderer) { double }

    before(:each) do
      Motion.configure do |config|
        config.renderer_for_connection_proc = ->(input) do
          expect(input).to be(connection)
          renderer
        end
      end
    end

    it { is_expected.to be(renderer) }
  end

  describe ".notify_error", unconfigured: true do
    subject { described_class.notify_error(error, message) }

    let(:error) { double }
    let(:message) { double }

    it "forwards the error and message to the `error_notification_proc`" do
      Motion.configure do |config|
        config.error_notification_proc = ->(input_error, input_message) do
          expect(input_error).to be(error)
          expect(input_message).to be(message)
        end
      end

      subject
    end
  end

  describe ".compatible_client_version?" do
    subject { described_class.compatible_client_version?(client_version) }

    context "when the client version matches the server version" do
      let(:client_version) { Motion::VERSION }

      it { is_expected.to be_truthy }
    end

    context "when the client version is too old for the server" do
      let(:client_version) { "0.0.1" }

      it { is_expected.to be_falsey }
    end

    context "when the client version is too new for the server" do
      let(:client_version) { "100.10.1" }

      it { is_expected.to be_falsey }
    end
  end
end
