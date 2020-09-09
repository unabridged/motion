# frozen_string_literal: true

require "motion"

module Motion
  class Event
    def self.from_raw(raw)
      new(raw) if raw
    end

    attr_reader :raw

    def initialize(raw)
      @raw = raw.freeze
    end

    def type
      raw["type"]
    end

    alias_method :name, :type

    def details
      raw.fetch("details", {})
    end

    def extra_data
      raw["extraData"]
    end

    def target
      return @target if defined?(@target)

      @target = Motion::Element.from_raw(raw["target"])
    end

    def current_target
      return @current_target if defined?(@current_target)

      @current_target = Motion::Element.from_raw(raw["currentTarget"])
    end

    alias_method :element, :current_target

    def form_data
      element&.form_data
    end
  end
end
