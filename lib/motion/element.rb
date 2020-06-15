# frozen_string_literal: true

require "motion"

module Motion
  class Element
    def self.from_raw(raw)
      new(raw) if raw
    end

    attr_reader :raw

    def initialize(raw)
      @raw = raw.freeze
    end

    def inspect
      if value
        "#<#{self.class}(#{tag_name}) value: #{value.inspect}, ...>"
      else
        "#<#{self.class}(#{tag_name}) ...>"
      end
    end

    def tag_name
      raw["tagName"]
    end

    def value
      raw["value"]
    end

    def attributes
      raw.fetch("attributes", {})
    end

    def [](key)
      key = key.to_s

      attributes[key] || attributes[key.tr("_", "-")]
    end

    def id
      self[:id]
    end

    class DataAttributes
      attr_reader :element

      def initialize(element)
        @element = element
      end

      def [](data)
        element["data-#{data}"]
      end
    end

    private_constant :DataAttributes

    def data
      return @data if defined?(@data)

      @data = DataAttributes.new(self)
    end

    def form_data
      return @form_data if defined?(@form_data)

      @form_data =
        ActionController::Parameters.new(
          Rack::Utils.parse_nested_query(
            raw.fetch("formData", "")
          )
        )
    end
  end
end
