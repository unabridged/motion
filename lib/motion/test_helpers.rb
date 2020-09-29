# frozen_string_literal: true

require "motion"

module Motion
  module TestHelpers
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

    def motion_event(attributes = {})
      Motion::Event.new(ActiveSupport::JSON.decode(attributes.to_json))
    end
  end
end
