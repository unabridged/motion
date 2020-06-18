# frozen_string_literal: true

RSpec.describe Motion::Component::Motions do
  class ExampleComponent < ViewComponent::Base
    include Motion::Component

    map_motion :simple

    def simple(_event)
    end

    map_motion :no_argument

    def no_argument
    end

    map_motion "customName", :custom_name

    def custom_name(_event)
    end

    def add_dynamic_motion
      map_motion :dynamic_motion
    end

    def dynamic_motion(_event)
    end
  end

  subject(:component) { ExampleComponent.new }

  describe "#motions" do
    subject { component.motions }

    it { is_expected.to include("simple", "no_argument", "customName") }

    context "when a dynamic motion is added" do
      before(:each) { component.add_dynamic_motion }

      it { is_expected.to include("dynamic_motion") }
    end
  end

  describe "process_motion" do
    subject { component.process_motion(motion, event) }

    let(:event) { double(Motion::Event) }

    context "for a motion that takes an event" do
      let(:motion) { "simple" }

      it "calls the handler with the event" do
        expect(component).to receive(:simple).with(event)
        subject
      end
    end

    context "for a motion that does not take an event" do
      let(:motion) { "no_argument" }

      it "calls the handler without the event" do
        expect(component).to receive(:no_argument)
        subject
      end
    end

    context "for a motion which is not mapped" do
      let(:motion) { "invalid" }

      it "raises MotionNotMapped" do
        expect { subject }.to raise_error(Motion::MotionNotMapped)
      end
    end
  end
end
