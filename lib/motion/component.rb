# frozen_string_literal: true

require "active_support/concern"

require "motion"

require "motion/component/broadcasts"
require "motion/component/lifecycle"
require "motion/component/motions"
require "motion/component/rendering"

module Motion
  module Component
    extend ActiveSupport::Concern

    include Broadcasts
    include Lifecycle
    include Motions
    include Rendering
  end
end
