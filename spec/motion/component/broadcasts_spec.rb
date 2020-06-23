# frozen_string_literal: true

RSpec.describe Motion::Component::Broadcasts do
  describe described_class::ClassMethods do
    subject(:component_class) do # We need a fresh class for every spec
      stub_const("TemporaryComponent", Class.new(ViewComponent::Base) {
        include Motion::Component

        def noop
        end
      })
    end

    let(:component) { component_class.new }

    describe "#broadcast_to" do
      subject { component_class.broadcast_to(model, message) }

      let(:model) { SecureRandom.hex }
      let(:message) { SecureRandom.hex }
      let(:broadcast) { component_class.broadcasting_for(model) }

      it "broadcasts the message to the topic for the model" do
        expect(ActionCable.server).to(
          receive(:broadcast).with(broadcast, message)
        )

        subject
      end
    end

    describe "#stream_from" do
      subject! { component_class.stream_from(broadcast, :noop) }

      let(:broadcast) { SecureRandom.hex }

      it "causes instances of the component to stream from the broadcast" do
        expect(component.broadcasts).to include(broadcast)
      end
    end

    describe "#stream_for" do
      subject! { component_class.stream_for(model, :noop) }

      let(:model) { SecureRandom.hex }
      let(:broadcast) { component_class.broadcasting_for(model) }

      it "causes instances to stream from the topic for the model" do
        expect(component.broadcasts).to include(broadcast)
      end
    end

    describe "#broadcasting_for" do
      subject { component_class.broadcasting_for(model) }

      let(:model) { SecureRandom.hex }

      it "prefixes the component class" do
        is_expected.to start_with(component_class.name)
      end
    end
  end

  subject(:component) { TestComponent.new }

  describe "#broadcasts" do
    subject { component.broadcasts }

    it { is_expected.to contain_exactly(*TestComponent::STATIC_BROADCASTS) }

    context "when a dynamic broadcast is added" do
      before(:each) { component.setup_dynamic_stream }

      it { is_expected.to include(TestComponent::DYNAMIC_BROADCAST) }
    end
  end

  describe "#process_broadcast" do
    subject { component.process_broadcast(broadcast, message) }

    let(:message) { SecureRandom.hex }

    context "for a broadcast the component is streaming from" do
      let(:broadcast) { TestComponent::STATIC_BROADCASTS.sample }

      it "invokes the corresponding handler" do
        expect(component).to receive(broadcast).with(message)
        subject
      end
    end

    context "for a broadcast the component is *not* streaming from" do
      let(:broadcast) { "random-broadcast:#{SecureRandom.hex}" }

      it "does not invoke the corresponding handler" do
        expect(component).not_to receive(broadcast)
        subject
      end
    end
  end

  describe "#stream_from" do
    subject! { component.stream_from(broadcast, :noop) }

    let(:broadcast) { SecureRandom.hex }

    it "streams from the broadcast" do
      expect(component.broadcasts).to include(broadcast)
    end
  end

  describe "#stream_for" do
    subject! { component.stream_for(model, :noop) }

    let(:model) { SecureRandom.hex }
    let(:broadcast) { component.class.broadcasting_for(model) }

    it "streams from the topic for the model" do
      expect(component.broadcasts).to include(broadcast)
    end
  end
end
