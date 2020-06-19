# frozen_string_literal: true

RSpec.describe Motion::Component::Motions do
  subject(:component) { TestComponent.new }

  describe "#motions" do
    subject { component.motions }

    it { is_expected.to contain_exactly(*TestComponent::STATIC_MOTIONS) }

    context "when a dynamic motion is added" do
      before(:each) { component.setup_dynamic_motion }

      it { is_expected.to include(TestComponent::DYNAMIC_MOTION) }
    end
  end

  describe "#process_motion" do
    subject { component.process_motion(motion, event) }

    let(:event) { Motion::Event.new({}) }

    context "for a motion that takes an event" do
      let(:motion) { "noop_with_event" }

      it "calls the handler with the event" do
        expect(component).to receive(:noop_with_event).with(event)
        subject
      end
    end

    context "for a motion that does not take an event" do
      let(:motion) { "noop_without_event" }

      it "calls the handler without the event" do
        # Sadly, the way rspec's mocking works, this will change the arity:
        #   expect(component).to receive(:noop_without_event).with(no_args)
        #
        # Instead we roll out own watcher that we know will take 0 args:
        called = false

        component.define_singleton_method(:noop_without_event) do
          called = true
          super()
        end

        subject

        expect(called).to be(true)
      end
    end

    context "for a motion which is not mapped" do
      let(:motion) { "invalid_#{SecureRandom.hex}" }

      it "raises MotionNotMapped" do
        expect { subject }.to raise_error(Motion::MotionNotMapped)
      end
    end
  end
end
