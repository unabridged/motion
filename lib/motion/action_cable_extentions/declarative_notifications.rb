# frozen_string_literal: true

require "motion"

module Motion
  module ActionCableExtentions
    # Provides a `periodicly_notify(broadcasts, to:)` API that can be used to
    # declaratively specify when a handler should be called.
    module DeclarativeNotifications
      include Synchronization

      def initialize(*)
        super

        # The current set of declartive notifications
        @_declarative_notifications = {}

        # The active timers for the declartive notifications
        @_declarative_notification_timers = {}

        # The method we are routing declarative notifications to
        @_declarative_notifications_target = nil
      end

      def declarative_notifications
        @_declarative_notifications.keys
      end

      def periodicly_notify(notifications, via:)
        (@_declarative_notifications.to_a - notifications.to_a)
          .each do |notification, _interval|
            _shutdown_declarative_notifcation_timer(notification)
          end

        (notifications.to_a - @_declarative_notifications.to_a)
          .each do |notification, interval|
            _setup_declarative_notifcation_timer(notification, interval)
          end

        @_declarative_notifications.replace(notifications)
        @_declarative_notifications_target = via
      end

      private

      def stop_periodic_timers
        super

        @_declarative_notification_timers.clear
      end

      # Sadly, the only public interface in ActionCable for defining periodic
      # timers is exposed at the class level. Looking at the source though,
      # it is easy to see that new timers can be setup with
      # `start_periodic_timer`. To ensure that we do not leak any timers, it is
      # important to store these intances in `active_periodic_timers` so that
      # ActionCable cleans them up for use when the channel shuts down.
      #
      # See `ActionCable::Channel::PeriodicTimers` for details.
      def _setup_declarative_notifcation_timer(notification, interval)
        return if connection.is_a?(ActionCable::Channel::ConnectionStub) ||
          @_declarative_notification_timers.include?(notification)

        callback = proc do
          synchronize_entrypoint! do
            _handle_declarative_notifcation(notification)
          end
        end

        timer = start_periodic_timer(callback, every: interval)

        @_declarative_notification_timers[notification] = timer
        active_periodic_timers << timer
      end

      def _shutdown_declarative_notifcation_timer(notification, *)
        timer = @_declarative_notification_timers.delete(notification)
        return unless timer

        timer.shutdown
        active_periodic_timers.delete(timer)
      end

      def _handle_declarative_notifcation(notification)
        return unless @_declarative_notifications_target &&
          @_declarative_notifications.include?(notification)

        send(@_declarative_notifications_target, notification)
      end
    end
  end
end
