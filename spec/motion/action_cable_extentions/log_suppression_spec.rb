# frozen_string_literal: true

RSpec.describe Motion::ActionCableExtentions::LogSuppression do
  class TestChannel < ApplicationCable::Channel
    include Motion::ActionCableExtentions::LogSuppression
  end

  describe TestChannel, type: :channel do
    before(:each) { subscribe }

    let(:connection_logger) { connection.logger }
    let(:channel_logger) { subscription.logger }

    it "silences `info` messages" do
      expect(connection_logger).not_to receive(:info)
      channel_logger.info("message")
    end

    it "silences `debug` messages" do
      expect(connection_logger).not_to receive(:debug)
      channel_logger.debug("message")
    end

    it "still allows `error` messages" do
      expect(connection_logger).to receive(:error)
      channel_logger.error("message")
    end
  end
end
