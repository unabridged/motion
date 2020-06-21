# frozen_string_literal: true

RSpec.describe Motion::LogHelper do
  subject(:log_helper) { described_class.new(logger: logger, tag: tag) }

  let(:logger) { Logger.new(File::NULL) }
  let(:tag) { SecureRandom.hex }

  describe ".for_channel" do
    subject { described_class.for_channel(channel) }

    let(:channel) do
      double(
        Motion::Channel,
        connection: double(
          ApplicationCable::Connection,
          logger: logger
        )
      )
    end

    it "creates a log helper for the connection's logger" do
      expect(subject.logger).to be(logger)
    end
  end

  describe ".for_component" do
    subject { described_class.for_component(component, logger: logger) }

    let(:component) { TestComponent.new }

    it "creates a log helper tagged for the component" do
      expect(subject.tag).to include("TestComponent")
    end
  end

  describe "#error" do
    subject { log_helper.error(message, error: error) }

    let(:message) { SecureRandom.hex }

    context "without an error" do
      let(:error) { nil }

      it "logs the message" do
        expect(logger).to receive(:error).with(/#{Regexp.quote(message)}/)
        subject
      end

      it "includes the log tag" do
        expect(logger).to receive(:error).with(/#{Regexp.quote(tag)}/)
        subject
      end
    end

    context "with an error" do
      let(:error) do
        # raise the error so that it has a backtrace

        raise
      rescue => error
        error
      end

      it "logs the message" do
        expect(logger).to receive(:error).with(/#{Regexp.quote(message)}/)
        subject
      end

      it "includes the log tag" do
        expect(logger).to receive(:error).with(/#{Regexp.quote(tag)}/)
        subject
      end

      it "includes the error message" do
        expect(logger).to receive(:error).with(/#{Regexp.quote(error.message)}/)
        subject
      end

      it "inclues the backtrace" do
        expect(logger).to(
          receive(:error).with(/#{Regexp.quote(error.backtrace.first)}/)
        )

        subject
      end
    end
  end

  describe "#info" do
    subject { log_helper.info(message) }

    let(:message) { SecureRandom.hex }

    it "logs the message" do
      expect(logger).to receive(:info).with(/#{Regexp.quote(message)}/)
      subject
    end

    it "includes the log tag" do
      expect(logger).to receive(:info).with(/#{Regexp.quote(tag)}/)
      subject
    end
  end

  describe "#timing" do
    subject { log_helper.timing(message, &block) }

    let(:message) { SecureRandom.hex }

    context "with a very fast block action" do
      let(:block) { proc {} }

      it "logs the message" do
        expect(logger).to receive(:info).with(/#{Regexp.quote(message)}/)
        subject
      end

      it "logs the timing" do
        expect(logger).to receive(:info).with(/in less than 0.1ms/)
        subject
      end
    end

    context "with a block that takes some time" do
      let(:block) { proc { sleep(duration_ms / 1000.0) } }
      let(:duration_ms) { rand(10..50) }

      it "logs the message" do
        expect(logger).to receive(:info).with(/#{Regexp.quote(message)}/)
        subject
      end

      it "logs the timing" do
        expect(logger).to(
          receive(:info).with(/in #{Regexp.quote(duration_ms.to_s)}(\.\d)?ms/)
        )

        subject
      end
    end
  end

  describe "#for_component" do
    subject { log_helper.for_component(component) }

    let(:component) { TestComponent.new }

    it "gives a new instance tagged for the component with the same logger" do
      expect(subject.logger).to eq(logger)
      expect(subject.tag).not_to eq(tag)
    end
  end
end
