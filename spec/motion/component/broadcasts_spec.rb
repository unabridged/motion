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

    describe "#stop_streaming_from" do
      subject { component_class.stop_streaming_from(broadcast) }

      context "for a topic that instances are set to stream from" do
        before(:each) { component_class.stream_from(broadcast, :noop) }

        let(:broadcast) { SecureRandom.hex }

        it "causes instances of the component not to stream from the topic" do
          subject
          expect(component.broadcasts).not_to include(broadcast)
        end
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

    describe "#stop_streaming_for" do
      subject { component_class.stop_streaming_for(model) }

      context "for a model that instances are set to stream for" do
        before(:each) { component_class.stream_for(model, :noop) }

        let(:model) { SecureRandom.hex }
        let(:broadcast) { component_class.broadcasting_for(model) }

        it "causes instances of the component not to stream from the topic" do
          subject
          expect(component.broadcasts).not_to include(broadcast)
        end
      end
    end

    describe "#broadcasting_for" do
      subject { component_class.broadcasting_for(model) }

      let(:model) { SecureRandom.hex }

      it "prefixes the component class" do
        is_expected.to start_with(component_class.name)
      end

      context "with an object that supports global id" do
        let(:model) { double(to_gid_param: global_id) }
        let(:global_id) { SecureRandom.hex }

        it { is_expected.to include(global_id) }
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
      let(:handler) { broadcast.to_sym }

      it "invokes the corresponding handler" do
        expect(component).to receive(handler).with(message)
        subject
      end

      it "runs the action callbacks with the context of the handler" do
        expect(component).to(
          receive(:_run_action_callbacks).with(context: handler)
        )

        subject
      end
    end

    context "for a broadcast the component is *not* streaming from" do
      let(:broadcast) { "random-broadcast:#{SecureRandom.hex}" }

      it "does not invoke the corresponding handler" do
        expect(component).not_to receive(broadcast)
        subject
      end

      it "does not run the action callbacks" do
        expect(component).not_to receive(:_run_action_callbacks)
      end
    end

    context "for a broadcast that takes a message" do
      let(:broadcast) { "noop_with_arg" }

      it "calls the handler with the message" do
        expect(component).to receive(:noop_with_arg).with(message)
        subject
      end
    end

    context "for a broadcast that does not take a message" do
      let(:broadcast) { "noop_without_arg" }

      it "calls the handler without the argument" do
        # Sadly, the way rspec's mocking works, this will change the arity:
        #   expect(component).to receive(:noop_without_event).with(no_args)
        #
        # Instead we roll out own watcher that we know will take 0 args:
        called = false

        component.define_singleton_method(:noop_without_arg) do
          called = true
          super()
        end

        subject

        expect(called).to be(true)
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

  describe "#stop_streaming_from" do
    subject! { component.stop_streaming_from(broadcast) }

    context "for a broadcast the component is streaming from" do
      let(:broadcast) { TestComponent::STATIC_BROADCASTS.sample }

      it "causes the component to stop to streaming from the broadcast" do
        expect(component.broadcasts).not_to include(broadcast)
      end
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

  describe "#stop_streaming_for" do
    subject { component.stop_streaming_for(model) }

    context "for a model the component is streaming for" do
      before(:each) { component.stream_for(model, :noop) }

      let(:model) { SecureRandom.hex }
      let(:broadcast) { component.class.broadcasting_for(model) }

      it "causes the component to stop to streaming from the broadcast" do
        subject
        expect(component.broadcasts).not_to include(broadcast)
      end
    end
  end
end
