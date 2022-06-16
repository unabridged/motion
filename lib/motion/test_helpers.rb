# frozen_string_literal: true

require "motion"

module Motion
  module TestHelpers
    class MockComponent < ViewComponent::Base
      include Motion::Component
    end

    def callback_stub(method_name = :bound)
      Motion::Callback.new(MockComponent.new, method_name)
    end

    def assert_motion(component, motion_name)
      assert motion?(component, motion_name)
    end

    def refute_motion(component, motion_name)
      refute motion?(component, motion_name)
    end

    def motion?(component, motion_name)
      component.motions.include?(motion_name.to_s)
    end

    def run_motion(component, motion_name, event = motion_event)
      if block_given?
        c = component.dup
        c.process_motion(motion_name.to_s, event)
        yield c
      else
        component.process_motion(motion_name.to_s, event)
      end
    end

    def process_broadcast(component, method_name, msg)
      callback = component.bind(method_name)
      component.process_broadcast(callback.broadcast, msg)
    end

    def assert_timer(component, method_name, interval)
      assert_equal interval, component.periodic_timers[method_name.to_s]
    end

    def refute_timer(component, method_name)
      refute timer?(component, method_name)
    end

    def timer?(component, method_name)
      component.periodic_timers.include?(method_name.to_s)
    end

    def motion_event(attributes = {})
      Motion::Event.new(ActiveSupport::JSON.decode(attributes.to_json)).tap do |event|
        set_form_data(event, attributes)
      end
    end

    private

    def set_form_data(event, attrs)
      return event unless attrs.fetch(:element, nil)

      form_data = attrs.dig(:element, :formData) || {}
      params = ActionController::Parameters.new(form_data)
      event.element.instance_variable_set(:@form_data, params)
    end
  end
end
