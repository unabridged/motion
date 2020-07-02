# frozen_string_literal: true

RSpec.describe Motion::Component::PeriodicTimers do
  describe described_class::ClassMethods do
    subject(:component_class) do # We need a fresh class for every spec
      stub_const("TemporaryComponent", Class.new(ViewComponent::Base) {
        include Motion::Component

        def noop
        end
      })
    end

    let(:component) { component_class.new }

    describe "#every" do
      subject! { component_class.every(interval, handler) }

      let(:interval) { rand(1..10) }
      let(:handler) { :noop }

      it "registers the handler to be invoked at the interval" do
        expect(component.periodic_timers[handler.to_s]).to eq(interval)
      end
    end

    describe "#periodic_timer" do
      subject! do
        component_class.periodic_timer(name, handler, every: interval)
      end

      let(:name) { SecureRandom.hex }
      let(:interval) { rand(1..10) }
      let(:handler) { :noop }

      it "sets up a new periodic timer" do
        expect(component.periodic_timers[name]).to eq(interval)
      end
    end

    describe "#stop_periodic_timer" do
      subject { component_class.stop_periodic_timer(name) }

      context "with a timer that has already been setup" do
        before(:each) { component_class.periodic_timer(name, :noop, every: 1) }

        let(:name) { SecureRandom.hex }

        it "removes the periodic timer" do
          subject
          expect(component.periodic_timers).not_to include(name)
        end
      end
    end

    describe "#periodic_timers" do
      subject { component_class.periodic_timers }

      it "gives the default periodic timers for the instance" do
        expect(subject).to eq(component.periodic_timers)
      end
    end
  end

  subject(:component) { TestComponent.new }

  describe "#process_periodic_timer" do
    subject { component.process_periodic_timer(name) }

    context "with a timer that is registered" do
      let(:name) { "noop" }

      it "invokes the corresponding handler" do
        expect(component).to receive(:noop)
        subject
      end
    end

    context "with a timer that is not registered" do
      let(:name) { SecureRandom.hex }

      it "does not invoke the corresponding handler" do
        expect(component).not_to receive(name)
        subject
      end
    end
  end

  describe "#every" do
    subject! { component.every(interval, handler) }

    let(:interval) { rand(1..10) }
    let(:handler) { :noop }

    it "registers the handler to be invoked at the interval" do
      expect(component.periodic_timers[handler.to_s]).to eq(interval)
    end
  end

  describe "#periodic_timer" do
    subject! { component.periodic_timer(name, handler, every: interval) }

    let(:name) { SecureRandom.hex }
    let(:interval) { rand(1..10) }
    let(:handler) { :noop }

    it "sets up a new periodic timer" do
      expect(component.periodic_timers[name]).to eq(interval)
    end
  end

  describe "#stop_periodic_timer" do
    subject! { component.stop_periodic_timer(name) }

    context "with a timer that is registered" do
      let(:name) { "noop" }

      it "removes the periodic timer" do
        expect(component.periodic_timers).not_to include(name)
      end
    end
  end

  describe "#periodic_timers" do
    subject { component.periodic_timers }

    it "gives the periodic timers for the component" do
      expect(subject.keys).to contain_exactly(*TestComponent::STATIC_TIMERS)
    end
  end
end
