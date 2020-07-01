# frozen_string_literal: true

RSpec.describe Motion::ComponentConnection do
  subject(:component_connection) { described_class.new(component) }

  let(:component) { TestComponent.new }

  describe ".from_state" do
    subject { described_class.from_state(state) }

    let(:state) do
      _key, state = Motion.serializer.serialize(component)

      state
    end

    it "wraps the component for the state" do
      key_a, _state = Motion.serializer.serialize(component)
      key_b, _state = Motion.serializer.serialize(subject.component)

      expect(key_a).to eq(key_b)
    end
  end

  it "calls the component's #connected callback" do
    expect_any_instance_of(TestComponent).to receive(:connected)

    subject
  end

  it "logs the timing for connecting the component" do
    expect(Rails.logger).to receive(:info).with(/Connected/)

    subject
  end

  context "when the component's #connected callback raises" do
    let(:component) { TestComponent.new(connected: :raise_error) }

    it "cannot be constructed" do
      expect { subject }.to raise_error(/Error from TestComponent/)
    end
  end

  describe "#close" do
    subject { component_connection.close }

    before(:each) { component_connection }

    it "calls the component's #disconnected callback" do
      expect_any_instance_of(TestComponent).to receive(:disconnected)

      subject
    end

    it "logs the timing for disconnecting the component" do
      expect(Rails.logger).to receive(:info).with(/Disconnected/)

      subject
    end

    context "when an error occurs in the #disconnected callback" do
      let(:component) { TestComponent.new(disconnected: :raise_error) }

      it "logs the error and returns false" do
        expect(Rails.logger).to receive(:error).with(/Error from TestComponent/)

        expect(subject).to be(false)
      end
    end
  end

  describe "#process_periodic_timer" do
    subject { component_connection.process_periodic_timer(timer) }

    before(:each) { component_connection }

    let(:timer) { SecureRandom.hex }

    it "processes the timer callback on the underlying component" do
      expect_any_instance_of(TestComponent).to(
        receive(:process_periodic_timer).with(timer)
      )

      subject
    end

    it "logs the timing for processing the timer" do
      expect(Rails.logger).to receive(:info).with(/timer/)

      subject
    end

    context "when an error occurs while processing the timer" do
      let(:timer) { "raise_error" }

      it "logs the error and returns false" do
        expect(Rails.logger).to receive(:error).with(/Error from TestComponent/)

        expect(subject).to be(false)
      end
    end
  end

  describe "#if_render_required" do
    subject(:yielded?) do
      yielded = false

      component_connection.if_render_required do
        yielded = true
      end

      yielded
    end

    before(:each) { component_connection }

    context "initially" do
      it "does not yield and logs no timing information" do
        expect(Rails.logger).not_to receive(:info)
        expect(yielded?).to be(false)
      end
    end

    context "whan a component does not need to re-render" do
      before(:each) { component_connection.process_motion("noop") }

      it "does not yield and logs no timing information" do
        expect(Rails.logger).not_to receive(:info)
        expect(yielded?).to be(false)
      end
    end

    context "when component undergoes a state change" do
      before(:each) { component_connection.process_motion("change_state") }

      it "yields and logs the timing information" do
        expect(Rails.logger).to receive(:info).with(/Rendered/)

        expect(yielded?).to be(true)
      end
    end

    context "when a component forces a rerender" do
      before(:each) { component_connection.process_motion("force_rerender") }

      it "yields and logs the timing information" do
        expect(Rails.logger).to receive(:info).with(/Rendered/)
        expect(yielded?).to be(true)
      end
    end
  end

  describe "#broadcasts" do
    subject { component_connection.broadcasts }

    it "gives the broadcasts of the underlying component" do
      expect(subject).to eq(component.broadcasts)
    end
  end

  describe "#periodic_timers" do
    subject { component_connection.periodic_timers }

    it "gives the periodic timers of the underlying component" do
      expect(subject).to eq(component.periodic_timers)
    end
  end
end
