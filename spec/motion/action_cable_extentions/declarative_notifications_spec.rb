# frozen_string_literal: true

# TODO: These unit tests are very lacking because of the stubbing done by the
# ActionCable test helpers. There currently does not seem to be any way to setup
# real periodic timers
RSpec.describe Motion::ActionCableExtentions::DeclarativeNotifications do
  class TestChannel < ApplicationCable::Channel
    include Motion::ActionCableExtentions::DeclarativeNotifications
  end

  describe TestChannel, type: :channel do
    before(:each) { subscribe }

    describe "#periodically_notify" do
      subject! { subscription.periodically_notify(timers, via: target) }

      let(:timers) do
        Array.new(rand(1..10)) { [SecureRandom.hex, rand(10..20)] }.to_h
      end

      let(:target) { :"handle_timer_#{SecureRandom.hex}" }

      it "sets the declarative notifications" do
        expect(subscription.declarative_notifications).to(
          contain_exactly(*timers)
        )
      end

      it "sets the handler to the provided target" do
        expect(subscription.declarative_notifications_target).to eq(target)
      end
    end
  end
end
