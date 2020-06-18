# frozen_string_literal: true

RSpec.describe Motion::Component::Lifecycle do
  class ExampleComponent < ViewComponent::Base
    include Motion::Component
  end

  describe ".upgrade_from" do
    subject { ExampleComponent.upgrade_from(revision, instance) }

    let(:revision) { "previous-revision" }
    let(:instance) { ExampleComponent.new }

    it "raises IncorrectRevisionError" do
      expect { subject }.to raise_error(Motion::IncorrectRevisionError)
    end
  end

  subject { ExampleComponent.new }

  it { is_expected.to respond_to(:connected) }
  it { is_expected.to respond_to(:disconnected) }
end
