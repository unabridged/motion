# frozen_string_literal: true

require "motion"

module Motion
  module ActionCableExtentions
    # By default ActionCable logs a lot. This module suppresses the debugging
    # information on a _per channel_ basis.
    module LogSuppression
      class Suppressor < SimpleDelegator
        def info(*)
        end

        def debug(*)
        end
      end

      private_constant :Suppressor

      def initialize(*)
        super

        @_logger = Suppressor.new(logger)
      end

      def logger
        return super unless defined?(@_logger)

        @_logger
      end
    end
  end
end
