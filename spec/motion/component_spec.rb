# frozen_string_literal: true

RSpec.describe Motion::Component do
  subject { TestComponent }

  it { is_expected.to include(Motion::Component::Broadcasts) }
  it { is_expected.to include(Motion::Component::Lifecycle) }
  it { is_expected.to include(Motion::Component::Motions) }
  it { is_expected.to include(Motion::Component::Rendering) }
end
