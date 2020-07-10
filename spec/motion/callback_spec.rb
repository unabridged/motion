# frozen_string_literal: true

RSpec.describe Motion::Callback do
  subject(:callback) { described_class.new(component, method) }

  let(:component) { TestComponent.new }
  let(:method) { :noop }

  let(:identifier) { component.stable_instance_identifier_for_callbacks }

  describe ".broadcast_for" do
    subject { described_class.broadcast_for(component, method) }

    it { is_expected.to start_with("motion:callback") }
    it { is_expected.to include(identifier.to_s) }
    it { is_expected.to include(method.to_s) }
  end

  it "causes the component to stream from its broadcast" do
    subject
    expect(component.broadcasts).to include(callback.broadcast)
  end

  describe "#==" do
    subject { callback == other }

    context "with another callback for the same compoent and method" do
      let(:other) { described_class.new(component, method) }

      it { is_expected.to be_truthy }
    end

    context "with another callback for a different component" do
      let(:other) { described_class.new(different_component, method) }
      let(:different_component) { TestComponent.new }

      it { is_expected.to be_falsey }
    end

    context "with another callback for a different method" do
      let(:other) { described_class.new(component, different_method) }
      let(:different_method) { :change_state }

      it { is_expected.to be_falsey }
    end
  end

  describe "#call" do
    subject { callback.call(message) }

    let(:message) { double }

    it "broadcasts the provided message to the callback topic" do
      expect(ActionCable.server).to(
        receive(:broadcast).with(callback.broadcast, message)
      )

      subject
    end
  end
end
