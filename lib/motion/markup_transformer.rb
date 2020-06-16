# frozen_string_literal: true

require "nokogiri"

require "motion"

module Motion
  class MarkupTransformer
    STIMULUS_CONTROLLER_ATTRIBUTE = "data-controller"

    attr_reader :serializer,
      :stimulus_controller_identifier,
      :key_attribute,
      :state_attribute

    def initialize(
      serializer: Motion.serializer,
      stimulus_controller_identifier:
        Motion.config.stimulus_controller_identifier,
      key_attribute: Motion.config.key_attribute,
      state_attribute: Motion.config.state_attribute
    )
      @serializer = serializer
      @stimulus_controller_identifier = stimulus_controller_identifier
      @key_attribute = key_attribute
      @state_attribute = state_attribute
    end

    def add_state_to_html(component, html)
      key, state = serializer.serialize(component)

      transform_root(component, html) do |root|
        root[STIMULUS_CONTROLLER_ATTRIBUTE] =
          values(
            stimulus_controller_identifier,
            root[STIMULUS_CONTROLLER_ATTRIBUTE]
          )

        root[key_attribute] = key
        root[state_attribute] = state
      end
    end

    private

    def transform_root(component, html)
      fragment = Nokogiri::HTML::DocumentFragment.parse(html)
      root, *unexpected_others = fragment.children

      raise MultipleRootsError, component if unexpected_others.any?(&:present?)

      yield root

      fragment.to_html.html_safe
    end

    def values(*values, delimiter: " ")
      values
        .compact
        .flat_map { |value| value.split(delimiter) }
        .uniq
        .join(delimiter)
    end
  end
end
