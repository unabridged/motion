# frozen_string_literal: true

RSpec.describe Motion::Component::Callbacks do
  subject(:component) { TestComponent.new }

  describe "#bind" do
    subject { component.bind(method) }

    let(:method) { :noop }

    it "gives a callback bound to the component and method" do
      expect(subject).to eq(Motion::Callback.new(component, method))
    end
  end

  describe "#stable_instance_identifier_for_callbacks" do
    subject { component.stable_instance_identifier_for_callbacks }

    it "is unique to the instance" do
      expect(subject).not_to(
        eq(TestComponent.new.stable_instance_identifier_for_callbacks)
      )
    end

    let(:serializer) { Motion.serializer }
    let(:serialized) { serializer.serialize(component).last }
    let(:deserialized) { serializer.deserialize(serialized) }

    it "is preserved through serialization" do
      expect(subject).to(
        eq(deserialized.stable_instance_identifier_for_callbacks)
      )
    end
  end
end
