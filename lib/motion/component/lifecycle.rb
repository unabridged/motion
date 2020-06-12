# frozen_string_literal: true

require "active_support/concern"

require "motion"

module Motion
  module Component
    module Lifecycle
      extend ActiveSupport::Concern

      class_methods do
        def upgrade_from(previous_revision, _instance)
          raise IncorrectRevisionError.new(Motion.revision, previous_revision)
        end
      end

      def connected
      end

      def disconnected
      end
    end
  end
end
