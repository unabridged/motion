# frozen_string_literal: true

class TestChannel < ApplicationCable::Channel
  include Motion::ActionCableExtentions::DeclarativeStreams
end

# TODO: These unit tests are very lacking because of the stubbing done by the
# ActionCable test helpers. There currently does not seem to be any way to setup
# and handle a real broadcast.
RSpec.describe Motion::ActionCableExtentions::DeclarativeStreams do
  describe TestChannel, type: :channel do
    before(:each) { subscribe }

    describe "#streaming_from" do
      subject! { subscription.streaming_from(streams, to: target) }

      let(:streams) { Array.new(rand(1..10)) { SecureRandom.hex } }
      let(:target) { :"hand_broadcast_#{SecureRandom.hex}" }

      it "listens to the provided streams" do
        expect(subscription.streams).to include(*streams)
      end

      it "sets the handler to the provided target" do
        expect(subscription.declarative_stream_target).to eq(target)
      end
    end
  end
end
