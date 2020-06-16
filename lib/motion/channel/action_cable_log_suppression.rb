# frozen_string_literal: true

require "motion"

module Motion
  class Channel < ApplicationCable::Channel
    module ActionCableLogSuppression
      class Suppressor < SimpleDelegator
        def info(*)
        end

        def debug(*)
        end
      end

      private_constant :Suppressor

      def logger
        @_logger ||= Suppressor.new(super)
      end
    end
  end
end
