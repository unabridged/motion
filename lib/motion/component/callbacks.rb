# frozen_string_literal: true

require "securerandom"

require "motion"

module Motion
  module Component
    module Callbacks
      def bind(method)
        Callback.new(self, method)
      end

      def stable_instance_identifier_for_callbacks
        @_stable_instance_identifier_for_callbacks ||= SecureRandom.uuid
      end
    end
  end
end
