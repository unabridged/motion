# frozen_string_literal: true

RSpec.describe Motion::Component::Rendering do
  subject(:component) { TestComponent.new }

  describe "#rerender!" do
    subject { component.rerender! }

    it "sets the component to be rerendered" do
      expect { subject }.to(
        change { component.awaiting_forced_rerender? }
        .from(false)
        .to(true)
      )
    end
  end

  describe "#render_hash" do
    subject { component.render_hash }

    it "changes when the component's state changes" do
      expect { component.change_state }.to change { component.render_hash }
    end

    it "does not change when the component's state does not change" do
      expect { component.noop }.not_to change { component.render_hash }
    end
  end

  describe ".render_in" do
    subject { ApplicationController.render(component) }

    it "transforms the rendered markup" do
      expect(subject).to(
        include(
          Motion.config.key_attribute,
          Motion.config.state_attribute,
          Motion.config.stimulus_controller_identifier
        )
      )
    end

    context "when the component is awaiting a forced re-render" do
      before(:each) { component.rerender! }

      it "clears #awaiting_forced_rerender?" do
        expect { subject }.to(
          change { component.awaiting_forced_rerender? }
          .from(true)
          .to(false)
        )
      end
    end
  end
end
