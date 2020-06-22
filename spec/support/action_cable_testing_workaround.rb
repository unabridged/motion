# frozen_string_literal: true

# https://github.com/palkan/action-cable-testing/issues/76
if Rails::VERSION::MAJOR == 5
  require "action_cable/testing"
  require "rspec/rails/feature_check"

  RSpec::Rails::FeatureCheck.module_eval do
    module_function

    def has_action_cable_testing?
      true
    end
  end
end
