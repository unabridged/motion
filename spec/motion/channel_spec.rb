# frozen_string_literal: true

RSpec.describe Motion::Channel, type: :channel do
  let(:component) { TestComponent.new }
  let(:state) { Motion.serializer.serialize(component).last }
  let(:version) { Motion::VERSION }

  describe ".action_methods" do
    subject { described_class.action_methods }

    it { is_expected.to contain_exactly("process_motion") }
  end

  describe "#subscribed" do
    subject { subscribe(state: state, version: version) }

    shared_examples "succesfully mounted" do |render:|
      it "accepts the subscription" do
        subject
        expect(subscription).to be_confirmed
      end

      it "streams from all of the component's broadcasts" do
        subject
        expect(subscription.streams).to include(*component.broadcasts)
      end

      it "runs the component's `connected` callback" do
        expect_any_instance_of(TestComponent).to receive(:connected)
        subject
      end

      if render
        it "renders the component" do
          subject
          expect(transmissions.count).to eq(1)
        end
      else
        it "does *not* render the component" do
          subject
          expect(transmissions.count).to eq(0)
        end
      end
    end

    shared_examples "failed to mount" do
      it "rejects the subscription" do
        subject
        expect(subscription).to be_rejected
      end
    end

    context "when the client version is not supported" do
      let(:version) { "invalid" }
      it_behaves_like "failed to mount"
    end

    context "when the initial state is invalid" do
      let(:state) { "invalid" }
      it_behaves_like "failed to mount"
    end

    context "with a connected callback that does nothing" do
      let(:component) { TestComponent.new(connected: :noop) }
      it_behaves_like "succesfully mounted", render: false
    end

    context "with a connected callback that changes state" do
      let(:component) { TestComponent.new(connected: :change_state) }
      it_behaves_like "succesfully mounted", render: true
    end

    context "with a connected callback that forces rerender" do
      let(:component) { TestComponent.new(connected: :force_rerender) }
      it_behaves_like "succesfully mounted", render: true
    end

    context "with a connected callback that maps a motion" do
      let(:component) { TestComponent.new(connected: :setup_dynamic_motion) }
      it_behaves_like "succesfully mounted", render: true
    end

    context "with a connected callback that streams" do
      let(:component) { TestComponent.new(connected: :setup_dynamic_stream) }
      it_behaves_like "succesfully mounted", render: true

      it "sets up the new stream" do
        subject

        expect(subscription.streams).to(
          include(TestComponent::DYNAMIC_BROADCAST)
        )
      end
    end

    context "with a connected callback that raises an error" do
      let(:component) { TestComponent.new(connected: :raise_error) }
      it_behaves_like "failed to mount"
    end
  end

  describe "#unsubscribed" do
    subject { unsubscribe }

    before(:each) { subscribe(state: state, version: version) }

    shared_examples "dismounted" do
      it "runs the component's `disconnected` callback" do
        expect_any_instance_of(TestComponent).to receive(:disconnected)
        subject
      end

      it "does *not* render the component" do
        subject
        expect(transmissions.count).to eq(0)
      end
    end

    context "with a disconnected callback that does nothing" do
      let(:component) { TestComponent.new(disconnected: :noop) }
      it_behaves_like "dismounted"
    end

    context "with a disconnected callback that changes state" do
      let(:component) { TestComponent.new(disconnected: :change_state) }
      it_behaves_like "dismounted"
    end

    context "with a disconnected callback that forces rerender" do
      let(:component) { TestComponent.new(disconnected: :force_rerender) }
      it_behaves_like "dismounted"
    end

    context "with a disconnected callback that maps a motion" do
      let(:component) { TestComponent.new(disconnected: :setup_dynamic_motion) }
      it_behaves_like "dismounted"
    end

    context "with a disconnected callback that streams" do
      let(:component) { TestComponent.new(disconnected: :setup_dynamic_stream) }
      it_behaves_like "dismounted"
    end

    context "with a disconnected callback that raises an error" do
      let(:component) { TestComponent.new(disconnected: :raise_error) }
      it_behaves_like "dismounted"
    end
  end

  shared_examples "succesfully processed" do |render:|
    it "streams from all of the component's broadcasts" do
      subject
      expect(subscription.streams).to include(*component.broadcasts)
    end

    if render
      it "renders the component" do
        subject
        expect(transmissions.count).to eq(1)
      end
    else
      it "does *not* render the component" do
        subject
        expect(transmissions.count).to eq(0)
      end
    end
  end

  describe "#process_motion" do
    subject { perform :process_motion, name: motion, event: raw_event }

    before(:each) { subscribe(state: state, version: version) }

    let(:raw_event) { {} }

    context "with a handler that does nothing" do
      let(:motion) { "noop" }
      it_behaves_like "succesfully processed", render: false
    end

    context "with a handler that changes state" do
      let(:motion) { "change_state" }
      it_behaves_like "succesfully processed", render: true
    end

    context "with a handler that forces rerender" do
      let(:motion) { "force_rerender" }
      it_behaves_like "succesfully processed", render: true
    end

    context "with a handler that maps a motion" do
      let(:motion) { "setup_dynamic_motion" }
      it_behaves_like "succesfully processed", render: true
    end

    context "with a handler that streams" do
      let(:motion) { "setup_dynamic_stream" }
      it_behaves_like "succesfully processed", render: true

      it "sets up the new stream" do
        subject

        expect(subscription.streams).to(
          include(TestComponent::DYNAMIC_BROADCAST)
        )
      end
    end

    context "with a handler that raises an error" do
      let(:motion) { "raise_error" }
      it_behaves_like "succesfully processed", render: false
    end
  end

  describe "#process_broadcast" do
    # TODO: Sadly, there does not seem to be testing infrustructure for using
    # broadcasts. This also makes `DeclarativeStreams` very hard to test.
    subject { subscription.process_broadcast(stream, message) }

    before(:each) { subscribe(state: state, version: version) }

    let(:message) { SecureRandom.hex }

    context "with a handler that does nothing" do
      let(:stream) { "noop" }
      it_behaves_like "succesfully processed", render: false
    end

    context "with a handler that changes state" do
      let(:stream) { "change_state" }
      it_behaves_like "succesfully processed", render: true
    end

    context "with a handler that forces rerender" do
      let(:stream) { "force_rerender" }
      it_behaves_like "succesfully processed", render: true
    end

    context "with a handler that maps a motion" do
      let(:stream) { "setup_dynamic_motion" }
      it_behaves_like "succesfully processed", render: true
    end

    context "with a handler that streams" do
      let(:stream) { "setup_dynamic_stream" }
      it_behaves_like "succesfully processed", render: true

      it "sets up the new stream" do
        subject

        expect(subscription.streams).to(
          include(TestComponent::DYNAMIC_BROADCAST)
        )
      end
    end

    context "with a handler that raises an error" do
      let(:stream) { "raise_error" }
      it_behaves_like "succesfully processed", render: false
    end
  end
end
