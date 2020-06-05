# frozen_string_literal: true

require 'motion'

module Motion
  module TestHelpers
    def assert_motion_action(component, action_name)
      assert motion_action?(component, action_name)
    end

    def refute_motion_action(component, action_name)
      refute motion_action?(component, action_name)
    end

    def motion_action?(component, action_name)
      component.actions.include?(action_name.to_s)
    end

    def run_motion(component, action_name)
      unless motion_action?(component, action_name)
        raise NotImplementedError, "The motion action ##{action_name} is not mapped on #{component.class}."
      end

      if block_given?
        c = component.dup
        c.process_action(action_name.to_s)
        yield c
      else
        component.process_action(action_name.to_s)
      end
    end
  end
end
