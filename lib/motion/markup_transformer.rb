# frozen_string_literal: true

require "nokogiri"

require "motion"

module Motion
  class MarkupTransformer
    attr_reader :serializer,
      :key_attribute,
      :state_attribute

    def initialize(
      serializer: Motion.serializer,
      key_attribute: Motion.config.key_attribute,
      state_attribute: Motion.config.state_attribute
    )
      @serializer = serializer
      @key_attribute = key_attribute
      @state_attribute = state_attribute
    end

    def add_state_to_html(component, html)
      key, state = serializer.serialize(component)

      transform_root(component, html) do |root|
        root[key_attribute] = key
        root[state_attribute] = state
      end
    end

    private

    def transform_root(component, html)
      fragment = Nokogiri::HTML::DocumentFragment.parse(html)
      root, *unexpected_others = fragment.children

      if !root || unexpected_others.any?(&:present?)
        raise MultipleRootsError, component
      end

      yield root

      fragment.to_html.html_safe
    end
  end
end
