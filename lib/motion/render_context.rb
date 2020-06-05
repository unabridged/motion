# frozen_string_literal: true

require 'nokogiri'

require 'motion'

module Motion
  class RenderContext
    CURRENT_THREAD_GLOBAL = :"#{name}.current"
    private_constant :CURRENT_THREAD_GLOBAL

    class << self
      def current
        Thread.current[CURRENT_THREAD_GLOBAL]
      end

      private

      def current=(new_current)
        Thread.current[CURRENT_THREAD_GLOBAL] = new_current
      end
    end

    def self.render_in(component, view_context, &block)
      parent = current
      new_current = new(parent, component, view_context)

      begin
        self.current = new_current

        new_current.render(&block)
      ensure
        self.current = parent
      end
    end

    attr_reader :parent, :component, :view_context

    def initialize(parent, component, view_context)
      @parent = parent
      @component = component
      @view_context = view_context
    end

    CONTROLLER_ATTRIBUTE = 'data-controller'
    CONTROLLER_VALUE = 'motion'
    KEY_ATTRIBUTE = 'data-motion-key'
    STATE_ATTRIBUTE = 'data-motion-state'

    def render
      html = view_context.capture { yield }
      key, state = Motion.serializer.serialize(component)

      transform_root(html) do |root|
        root[CONTROLLER_ATTRIBUTE] =
          values(CONTROLLER_VALUE, root[CONTROLLER_ATTRIBUTE])

        root[KEY_ATTRIBUTE] = key if nested?

        root[STATE_ATTRIBUTE] = state
      end
    end

    private

    def nested?
      !root?
    end

    def root?
      !parent
    end

    def transform_root(html)
      fragment = Nokogiri::HTML::DocumentFragment.parse(html)
      root, *unexpected_others = fragment.children

      raise MultipleRootsError, component if unexpected_others.any?(&:present?)

      yield root

      fragment.to_html.html_safe
    end

    def values(*values, delimiter: ' ')
      values
        .compact
        .flat_map { |value| value.split(delimiter) }
        .uniq
        .join(delimiter)
    end
  end
end
