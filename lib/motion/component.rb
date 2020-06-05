# frozen_string_literal: true

require 'active_support/concern'

require 'motion'
require 'motion/component/actions'
require 'motion/component/broadcasts'
require 'motion/component/rendering'

module Motion
  module Component
    extend ActiveSupport::Concern

    include Actions
    include Broadcasts
    include Rendering

    def self.dehydrate(component)
      Motion.serializer.serialize(component)
    end

    def self.rehydrate(state)
      Motion.serializer.deserialize(state)
    end
  end
end
