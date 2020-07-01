# frozen_string_literal: true

require "motion"

module Motion
  module ActionCableExtentions
    autoload :DeclarativeNotifications,
      "motion/action_cable_extentions/declarative_notifications"

    autoload :DeclarativeStreams,
      "motion/action_cable_extentions/declarative_streams"

    autoload :LogSuppression,
      "motion/action_cable_extentions/log_suppression"

    autoload :Synchronization,
      "motion/action_cable_extentions/synchronization"
  end
end
