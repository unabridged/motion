# frozen_string_literal: true

RSpec.describe Motion::Component::Lifecycle do
  subject(:component) { TestComponent.new }

  describe described_class::ClassMethods do
    subject(:component_class) do # We need a fresh class for every spec
      stub_const("TemporaryComponent", Class.new(ViewComponent::Base) {
        include Motion::Component

        def noop
          yield if block_given?
        end
      })
    end

    let(:component) { component_class.new }

    describe "#upgrade_from" do
      subject { component_class.upgrade_from(revision, instance) }

      let(:revision) { SecureRandom.hex }
      let(:instance) { TestComponent.new }

      it "raises UpgradeNotImplementedError" do
        expect { subject }.to raise_error(Motion::UpgradeNotImplementedError)
      end
    end

    describe "#before_action" do
      subject! { component_class.before_action(:noop, **options) }

      let(:options) { {} }

      it "sets up an action callback" do
        expect(component).to receive(:noop)
        component._run_action_callbacks(context: :anything)
      end

      context "when the `only` option is used" do
        let(:options) { {only: :matching_context} }

        it "sets up an action callback that runs in the matching context" do
          expect(component).to receive(:noop)
          component._run_action_callbacks(context: :matching_context)
        end

        it "sets up an action callback that does *not* run in other contexts" do
          expect(component).not_to receive(:noop)
          component._run_action_callbacks(context: :other_context)
        end
      end

      context "when the `except` option is used" do
        let(:options) { {except: :matching_context} }

        it "sets up a callback that does *not* run in the matching context" do
          expect(component).not_to receive(:noop)
          component._run_action_callbacks(context: :matching_context)
        end

        it "sets up a callback that runs in other contexts" do
          expect(component).to receive(:noop)
          component._run_action_callbacks(context: :other_context)
        end
      end
    end

    describe "#around_action" do
      subject! { component_class.around_action(:noop, **options) }

      let(:options) { {} }

      it "sets up an action callback" do
        expect(component).to receive(:noop)
        component._run_action_callbacks(context: :anything)
      end

      context "when the `only` option is used" do
        let(:options) { {only: :matching_context} }

        it "sets up an action callback that runs in the matching context" do
          expect(component).to receive(:noop)
          component._run_action_callbacks(context: :matching_context)
        end

        it "sets up an action callback that does *not* run in other contexts" do
          expect(component).not_to receive(:noop)
          component._run_action_callbacks(context: :other_context)
        end
      end

      context "when the `except` option is used" do
        let(:options) { {except: :matching_context} }

        it "sets up a callback that does *not* run in the matching context" do
          expect(component).not_to receive(:noop)
          component._run_action_callbacks(context: :matching_context)
        end

        it "sets up a callback that runs in other contexts" do
          expect(component).to receive(:noop)
          component._run_action_callbacks(context: :other_context)
        end
      end
    end

    describe "#after_action" do
      subject! { component_class.after_action(:noop, **options) }

      let(:options) { {} }

      it "sets up an action callback" do
        expect(component).to receive(:noop)
        component._run_action_callbacks(context: :anything)
      end

      context "when the `only` option is used" do
        let(:options) { {only: :matching_context} }

        it "sets up an action callback that runs in the matching context" do
          expect(component).to receive(:noop)
          component._run_action_callbacks(context: :matching_context)
        end

        it "sets up an action callback that does *not* run in other contexts" do
          expect(component).not_to receive(:noop)
          component._run_action_callbacks(context: :other_context)
        end
      end

      context "when the `except` option is used" do
        let(:options) { {except: :matching_context} }

        it "sets up a callback that does *not* run in the matching context" do
          expect(component).not_to receive(:noop)
          component._run_action_callbacks(context: :matching_context)
        end

        it "sets up a callback that runs in other contexts" do
          expect(component).to receive(:noop)
          component._run_action_callbacks(context: :other_context)
        end
      end
    end

    describe "#after_connect" do
      subject! { component_class.after_connect(:noop) }

      it "sets up a connect callback" do
        expect(component).to receive(:noop)
        component._run_connect_callbacks
      end
    end

    describe "#after_disconnect" do
      subject! { component_class.after_disconnect(:noop) }

      it "sets up a disconnect callback" do
        expect(component).to receive(:noop)
        component._run_disconnect_callbacks
      end
    end
  end

  describe "#process_connect" do
    subject { component.process_connect }

    it "runs the connect callbacks" do
      expect(component).to receive(:_run_connect_callbacks)
      subject
    end

    context "with a component that is using the legacy lifecycle method" do
      before(:each) { component.define_singleton_method(:connected) { nil } }

      it "displays a deperacation warning and calls the legacy method" do
        expect(ActiveSupport::Deprecation).to receive(:warn)
        expect(component).to receive(:connected)

        subject
      end
    end
  end

  describe "#process_disconnect" do
    subject { component.process_disconnect }

    it "runs the disconnect callbacks" do
      expect(component).to receive(:_run_disconnect_callbacks)
      subject
    end

    context "with a component that is using the legacy lifecycle method" do
      before(:each) { component.define_singleton_method(:disconnected) { nil } }

      it "displays a deperacation warning and calls the legacy method" do
        expect(ActiveSupport::Deprecation).to receive(:warn)
        expect(component).to receive(:disconnected)

        subject
      end
    end
  end
end
