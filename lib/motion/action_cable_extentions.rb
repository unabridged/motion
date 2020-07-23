# frozen_string_literal: true

require "motion"

module Motion
  # This module contains additional behavior for ActionCable which is used by
  # Motion but not in principle unique to it. In the future, it may be possible
  # to lift some of these abstractions into ActionCable directly.
  #
  # @api private
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
