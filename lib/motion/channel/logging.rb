# frozen_string_literal: true

require "motion"

module Motion
  class Channel < ApplicationCable::Channel
    # TODO: Move to a new class.
    module Logging
      private

      def log_timing(action)
        start = Time.now

        yield
      ensure
        duration_ms = (Time.now - start) * 1000
        duration_human =
          if duration_ms < 0.1
            "less than 0.1ms"
          else
            "#{duration_ms.round(1)}ms"
          end

        log_info("#{action} (in #{duration_human})")
      end

      def log_info(message)
        connection.logger.info("[#{log_tag}] #{message}")
      end

      def log_processing_error(error, target)
        log_error(error, "An error occurred while processing #{target}")
      end

      def log_error(error, message = "An error occurred")
        connection.logger.error(
          [
            "[#{log_tag}] #{message}:",
            "  #{error.class}: #{error.message}",
            *error.backtrace.first(5).map { |line| "    #{line}" }
          ].join("\n")
        )
      end

      def log_tag
        component ? "#{component.class}:#{component.object_id}" : "Motion"
      end
    end
  end
end
