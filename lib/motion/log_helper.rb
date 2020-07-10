# frozen_string_literal: true

require "rails"
require "active_support/core_ext/string/indent"

require "motion"

module Motion
  class LogHelper
    BACKTRACE_FRAMES = 5
    DEFAULT_TAG = "Motion"

    def self.for_channel(channel, logger: channel.connection.logger)
      new(logger: logger, tag: DEFAULT_TAG)
    end

    def self.for_component(component, logger: nil)
      new(logger: logger, tag: "#{component.class}:#{component.object_id}")
    end

    attr_reader :logger, :tag

    def initialize(logger: nil, tag: nil)
      @logger = logger || Rails.logger
      @tag = tag || DEFAULT_TAG
    end

    def error(message, error: nil)
      error_info = error ? ":\n#{indent(format_exception(error))}" : ""

      logger.error("[#{tag}] #{message}#{error_info}")

      Motion.notify_error(error, message)
    end

    def info(message)
      logger.info("[#{tag}] #{message}")
    end

    def timing(message)
      start_time = Time.now
      result = yield
      end_time = Time.now

      info("#{message} (in #{format_duration(end_time - start_time)})")

      result
    end

    def for_component(component)
      self.class.for_component(component, logger: logger)
    end

    private

    def format_exception(exception)
      frames = exception.backtrace.first(BACKTRACE_FRAMES).join("\n")

      "#{exception.class}: #{exception}\n#{indent(frames)}"
    end

    def format_duration(duration)
      duration_ms = duration * 1000

      if duration_ms < 0.1
        "less than 0.1ms"
      else
        "#{duration_ms.round(1)}ms"
      end
    end

    def indent(string)
      string.indent(1, "\t")
    end
  end
end
