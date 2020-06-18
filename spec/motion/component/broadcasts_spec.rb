# frozen_string_literal: true

RSpec.describe Motion::Component::Broadcasts do
  class ExampleComponent < ViewComponent::Base
    include Motion::Component

    stream_from "static-broadcast", :handler

    def add_dynamic_broadcast
      stream_from "dynamic-broadcast", :handler
    end

    def handler(_message)
    end
  end

  subject(:component) { ExampleComponent.new }

  describe "#broadcasts" do
    subject { component.broadcasts }

    it { is_expected.to include "static-broadcast" }

    context "when a dynamic broadcast is added" do
      before(:each) { component.add_dynamic_broadcast }

      it { is_expected.to include "dynamic-broadcast" }
    end
  end

  describe "#process_broadcast" do
    subject { component.process_broadcast(broadcast, message) }

    let(:message) { SecureRandom.hex }

    context "for a broadcast the component is streaming from" do
      let(:broadcast) { "static-broadcast" }

      it "invokes the corresponding handler" do
        expect(component).to receive(:handler).with(message)
        subject
      end
    end

    context "for a broadcast the component is *not* streaming from" do
      let(:broadcast) { "random-broadcast" }

      it "does not invoke the corresponding handler" do
        expect(component).not_to receive(:handler)
        subject
      end
    end
  end
end
