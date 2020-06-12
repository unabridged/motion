# frozen_string_literal: true

require "nokogiri"

require "motion"

class MarkupTransformer
  # TODO: Make these state on the instance and allow for configuration
  CONTROLLER_ATTRIBUTE = "data-controller"
  CONTROLLER_VALUE = "motion"
  KEY_ATTRIBUTE = "data-motion-key"
  STATE_ATTRIBUTE = "data-motion-state"

  attr_reader :serializer

  def initialize(serializer:)
    @serializer = serializer
  end

  def add_state_to_html(component, html)
    key, state = serializer.serialize(component)

    transform_root(component, html) do |root|
      root[CONTROLLER_ATTRIBUTE] =
        values(CONTROLLER_VALUE, root[CONTROLLER_ATTRIBUTE])

      root[KEY_ATTRIBUTE] = key
      root[STATE_ATTRIBUTE] = state
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
