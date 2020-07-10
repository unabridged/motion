# frozen_string_literal: true

require "active_support/concern"

require "motion"

require "motion/component/broadcasts"
require "motion/component/callbacks"
require "motion/component/lifecycle"
require "motion/component/motions"
require "motion/component/periodic_timers"
require "motion/component/rendering"

module Motion
  module Component
    extend ActiveSupport::Concern

    include Broadcasts
    include Callbacks
    include Lifecycle
    include Motions
    include PeriodicTimers
    include Rendering
  end
end
