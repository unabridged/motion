# frozen_string_literal: true

require "motion"

module Motion
  module ActionCableExtentions
    # This module suppresses all non-error logging from ActionCable (for the
    # channel into which it is mixed).
    #
    # @api private
    module LogSuppression
      class Suppressor < SimpleDelegator
        def info(*)
        end

        def debug(*)
        end
      end

      private_constant :Suppressor

      # This method is called by ActionCable to get the logger for the channel.
      #
      # @private
      def logger
        return super unless defined?(@_logger)

        @_logger
      end

      private

      def initialize(*)
        super

        @_logger = Suppressor.new(logger)
      end
    end
  end
end
