# frozen_string_literal: true

require "active_support/concern"

require "motion"

require "motion/component/actions"
require "motion/component/broadcasts"
require "motion/component/lifecycle"
require "motion/component/rendering"

module Motion
  module Component
    extend ActiveSupport::Concern

    include Actions
    include Broadcasts
    include Lifecycle
    include Rendering
  end
end
