# frozen_string_literal: true

require "active_support/callbacks"
require "active_support/concern"
require "active_support/deprecation"

require "motion"

module Motion
  module Component
    module Lifecycle
      extend ActiveSupport::Concern

      include ActiveSupport::Callbacks

      included do
        define_callbacks :action, :connect, :disconnect

        # The built-in triggers defined on the target class will override ours.
        remove_method(:_run_action_callbacks)
      end

      class_methods do
        # TODO: "IncorrectRevisionError" doesn't make sense for this anymore.
        # It should probably be something like "CannotUpgrade" and the error
        # message should focus on how to handle deployments gracefully.
        def upgrade_from(previous_revision, _instance)
          raise IncorrectRevisionError.new(
            Motion.config.revision,
            previous_revision
          )
        end

        def before_action(*methods, **options, &block)
          set_action_callback(:before, *methods, **options, &block)
        end

        def around_action(*methods, **options, &block)
          set_action_callback(:around, *methods, **options, &block)
        end

        def after_action(*methods, **options, &block)
          set_action_callback(:after, *methods, **options, &block)
        end

        def after_connect(*methods, **options, &block)
          set_callback(:connect, :after, *methods, **options, &block)
        end

        def after_disconnect(*methods, **options, &block)
          set_callback(:disconnect, :after, *methods, **options, &block)
        end

        private

        def set_action_callback(kind, *methods, **options, &block)
          filters = Array(options.delete(:if))

          if (only = Array(options.delete(:only))).any?
            filters << action_callback_context_filter(only)
          end

          if (except = Array(options.delete(:except))).any?
            filters << action_callback_context_filter(except, invert: true)
          end

          set_callback(:action, kind, *methods, if: filters, **options, &block)
        end

        def action_callback_context_filter(contexts, invert: false)
          proc { contexts.include?(@_action_callback_context) ^ invert }
        end
      end

      def process_connect
        _run_connect_callbacks

        # TODO: Remove at next minor release
        if respond_to?(:connected)
          ActiveSupport::Deprecation.warn(
            "The `connected` lifecycle method is being replaced by the " \
            "`after_connect` callback and will no longer be automatically " \
            "invoked in the next **minor release** of Motion."
          )

          send(:connected)
        end
      end

      def process_disconnect
        _run_disconnect_callbacks

        # TODO: Remove at next minor release
        if respond_to?(:disconnected)
          ActiveSupport::Deprecation.warn(
            "The `disconnected` lifecycle method is being replaced by the " \
            "`after_disconnect` callback and will no longer be automatically " \
            "invoked in the next **minor release** of Motion."
          )

          send(:disconnected)
        end
      end

      def _run_action_callbacks(context:, &block)
        @_action_callback_context = context

        run_callbacks(:action, &block)
      ensure
        # `@_action_callback_context = nil` would still appear in the state
        remove_instance_variable(:@_action_callback_context)
      end
    end
  end
end
