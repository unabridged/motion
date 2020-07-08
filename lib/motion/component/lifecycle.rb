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

        def before_action(*args, &block)
          set_callback(:action, :before, *args, &block)
        end

        def around_action(*args, &block)
          set_callback(:action, :around, *args, &block)
        end

        def after_action(*args, &block)
          set_callback(:action, :after, *args, &block)
        end

        def after_connect(*args, &block)
          set_callback(:connect, :after, *args, &block)
        end

        def after_disconnect(*args, &block)
          set_callback(:disconnect, :after, *args, &block)
        end
      end

      def process_connect
        run_callbacks(:connect)

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
        run_callbacks(:disconnect)

        if respond_to?(:disconnected)
          ActiveSupport::Deprecation.warn(
            "The `disconnected` lifecycle method is being replaced by the " \
            "`after_disconnect` callback and will no longer be automatically " \
            "invoked in the next **minor release** of Motion."
          )

          send(:disconnected)
        end
      end

      private

      def _run_action_callbacks(&block)
        run_callbacks(:action, &block)
      end
    end
  end
end
