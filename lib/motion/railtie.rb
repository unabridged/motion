# frozen_string_literal: true

require "motion"

module Motion
  class MyRailtie < Rails::Railtie
    generators do
      require_relative "../generators/motion/install_generator"
    end
  end
end