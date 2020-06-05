# frozen_string_literal: true

require 'active_support/concern'
require 'nokogiri'

require 'motion'
require 'motion/component'

module Motion
  module Component
    module Rendering
      extend ActiveSupport::Concern

      class MultipleRootsError < Motion::Error
        def initialize
          super(<<~MSG) # TODO: Better message (Focus on "How do I fix this?")
            You can only have one root element in your component.
          MSG
        end
      end

      class BlockNotAllowedError < Motion::Error
        def initialize
          super(<<~MSG) # TODO: Better message (Focus on "How do I fix this?")
            Rendering with a block is not supported with motion.

            Hint: Use a plain component instead and wrap with a motion component.
          MSG
        end
      end

      CONTROLLER_ATTRIBUTE = 'data-controller'
      CONTROLLER_VALUE = 'motion'
      KEY_ATTRIBUTE = 'data-motion-key'
      STATE_ATTRIBUTE = 'data-motion-state'

      RENDERING_VAR = :"#{name}.rendering"
      private_constant :RENDERING_VAR

      def self.rendering!
        was_rendering = Thread.current[RENDERING_VAR]

        begin
          Thread.current[RENDERING_VAR] = true

          yield was_rendering
        ensure
          Thread.current[RENDERING_VAR] = was_rendering
        end
      end

      # TODO: Move elsewhere -- used by rendering but does not characterize it
      def self.transform_root(html)
        fragment = Nokogiri::HTML::DocumentFragment.parse(html)
        root, *unexpected_others = fragment.children

        raise MultipleRootsError if unexpected_others.any?(&:present?)

        yield root

        fragment.to_html.html_safe
      end

      # TODO: Move elsewhere -- used by rendering but does not characterize it
      def self.values(*values, delimiter: ' ')
        values
          .compact
          .flat_map { |value| value.split(delimiter) }
          .uniq
          .join(delimiter)
      end

      def self.add_component_state_to_rendered_html(component, html, nested:)
        key, state = Component.dehydrate(component)

        transform_root(html) do |root|
          root[CONTROLLER_ATTRIBUTE] =
            values(CONTROLLER_VALUE, root[CONTROLLER_ATTRIBUTE])

          # The key attribute must be excluded from the top-level component for
          # reconciliation to work properly. Excluding the key here means "take
          # the value that is already there".
          root[KEY_ATTRIBUTE] = key if nested

          root[STATE_ATTRIBUTE] = state
        end
      end

      def render_in(view_context)
        raise BlockNotAllowedError if block_given?

        Rendering.rendering! do |nested|
          rendered_html = view_context.capture { without_new_instance_variables { super } }

          Rendering.add_component_state_to_rendered_html(self, rendered_html, nested: nested)
        end
      end

      private

      # TODO: Remove exactly the ivars added by ActionView (eg @view_context and friends)
      # and warn if we find any before rendering (ivars from the user which may clash with
      # ActionView)
      def without_new_instance_variables
        existing_instance_variables = instance_variables

        yield
      ensure
        (instance_variables - existing_instance_variables)
          .each(&method(:remove_instance_variable))
      end
    end
  end
end
