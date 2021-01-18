# frozen_string_literal: true

RSpec.describe Motion::Component::Rendering do
  subject(:component) { TestComponent.new }

  describe "#rerender!" do
    subject { component.rerender! }

    it "sets the component to be rerendered" do
      expect { subject }.to(
        change { component.awaiting_forced_rerender? }
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
    let(:controller) do
      Class.new(ApplicationController) do
        layout false
      end
    end

    subject { controller.render(component) }

    it "transforms the rendered markup" do
      expect(subject).to(
        include(
          Motion.config.key_attribute,
          Motion.config.state_attribute
        )
      )
    end

    it "runs the action callbacks with the context of `:render`" do
      expect(component).to(
        receive(:_run_action_callbacks).with(context: :render)
      )

      subject
    end

    context "when the component is awaiting a forced re-render" do
      before(:each) { component.rerender! }

      it "clears #awaiting_forced_rerender?" do
        expect { subject }.to(
          change { component.awaiting_forced_rerender? }
          .to(false)
        )
      end
    end

    context "when there is a render block" do
      subject do
        ApplicationController.render(inline: <<~ERB)
          <%= render(TestComponent.new) do %>
            block content
          <% end %>
        ERB
      end

      it "raises BlockNotAllowedError" do
        # ActionView will wrap our error, so we check the message.
        expect { subject }.to(
          raise_error(/Motion does not support rendering with a block/)
        )
      end
    end

    context "when the action callbacks abort" do
      let(:component) do
        stub_const("ActionAbortingComponent", Class.new(ViewComponent::Base) {
          include Motion::Component

          before_action { throw :abort }
        })

        ActionAbortingComponent.new
      end

      it "raises RenderAborted" do
        # ActionView will wrap our error, so we check the message.
        expect { subject }.to raise_error(/aborted by a callback/)
      end
    end
  end
end
