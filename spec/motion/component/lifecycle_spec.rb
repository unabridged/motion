# frozen_string_literal: true

RSpec.describe Motion::Component::Lifecycle do
  subject(:component) { TestComponent.new }

  it { is_expected.to respond_to(:connected) }
  it { is_expected.to respond_to(:disconnected) }

  describe described_class::ClassMethods do
    describe "#upgrade_from" do
      subject { TestComponent.upgrade_from(revision, instance) }

      let(:revision) { SecureRandom.hex }
      let(:instance) { TestComponent.new }

      it "raises IncorrectRevisionError" do
        expect { subject }.to raise_error(Motion::IncorrectRevisionError)
      end
    end
  end
end
