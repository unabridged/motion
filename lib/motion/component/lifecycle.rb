# frozen_string_literal: true

require "active_support/concern"

require "motion"

module Motion
  module Component
    module Lifecycle
      extend ActiveSupport::Concern

      class_methods do
        # TODO: "IncorrectRevisionError" doesn't make sense for this anymore.
        # It should probably be something like "CannotUpgrade" and the error
        # message should focus on how to handle deployments gracefully.
        def upgrade_from(previous_revision, _instance)
          raise IncorrectRevisionError.new(
            Motion.config.revision,
            previous_revision
          )
        end
      end

      def connected
      end

      def disconnected
      end
    end
  end
end
