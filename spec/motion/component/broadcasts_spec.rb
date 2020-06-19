# frozen_string_literal: true

RSpec.describe Motion::Component::Broadcasts do
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
end
