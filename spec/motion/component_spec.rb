# frozen_string_literal: true

RSpec.describe Motion::Component do
  class ExampleComponent < ViewComponent::Base
    include Motion::Component
  end

  subject { ExampleComponent }

  it { is_expected.to include(Motion::Component::Broadcasts) }
  it { is_expected.to include(Motion::Component::Lifecycle) }
  it { is_expected.to include(Motion::Component::Motions) }
  it { is_expected.to include(Motion::Component::Rendering) }
end
