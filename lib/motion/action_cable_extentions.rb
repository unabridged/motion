# frozen_string_literal: true

require "motion"

module Motion
  module ActionCableExtentions
    autoload :DeclarativeStreams,
      "motion/action_cable_extentions/declarative_streams"

    autoload :LogSuppression,
      "motion/action_cable_extentions/log_suppression"
  end
end
