# frozen_string_literal: true

require "motion"

module Motion
  module ActionCableExtentions
    # This module provides an API to setup a method on a channel to be called at
    # regular intervals. It differs from ActionCable's built-in +PeriodicTimers+
    # in that timers are managed at the instance level and only a single method
    # is called with a String (the "notification"). This scheme avoids the need
    # for any dynamic blocks which could not be +Marshal.dump+'d.
    #
    # @api private
    module DeclarativeNotifications
      include Synchronization

      # Configures a method to be called a regular intervals with particular
      # notification strings. As the module name suggests, this method is
      # "declarative" in that it will replace all existing notifications with
      # the notifications provided.
      #
      # @param notifications [Hash<String, Integer>]
      #   the notification strings mapped to the intervals at which they should
      #   be delivered
      #
      # @param via [Symbol]
      #   the method to which the notifications should be delivered
      def periodically_notify(notifications, via:)
        (@_declarative_notifications.to_a - notifications.to_a)
          .each do |notification, _interval|
            _shutdown_declarative_notifcation_timer(notification)
          end

        (notifications.to_a - @_declarative_notifications.to_a)
          .each do |notification, interval|
            _setup_declarative_notifcation_timer(notification, interval)
          end

        @_declarative_notifications = notifications
        @_declarative_notifications_target = via
      end

      # @return [Hash<String, Integer>]
      #   the current notification strings mapped to the intervals at which they
      #   are set to be delivered.
      #
      # @note
      #   This matches the +notifications+ argument of the last call to
      #   {#periodically_notify}.
      def declarative_notifications
        @_declarative_notifications
      end

      # @return [Symbol]
      #   the current method to which notifications are being delivered
      #
      # @note
      #   This matches the +via+ argument of the last call to
      #   {#periodically_notify}.
      def declarative_notifications_target
        @_declarative_notifications_target
      end

      private

      def initialize(*)
        super

        # The current set of declarative notifications
        @_declarative_notifications = {}

        # The active timers for the declarative notifications
        @_declarative_notifications_timers = {}

        # The method we are routing declarative notifications to
        @_declarative_notifications_target = nil
      end

      def stop_periodic_timers
        super

        @_declarative_notifications.clear
        @_declarative_notifications_timers.clear
        @_declarative_notifications_target = nil
      end

      # The only public interface in ActionCable for defining periodic timers is
      # exposed at the class level. Looking at the source though, it is easy to
      # see that new timers can be setup with `start_periodic_timer`. To ensure
      # that we do not leak any timers, it is important to store these instances
      # in `active_periodic_timers` so that ActionCable cleans them up for us
      # when the channel shuts down. Also, periodic timers are not supported by
      # the testing adapter, so we have to skip all of this in unit tests (it
      # _will_ be covered in systems tests though).
      #
      # See `ActionCable::Channel::PeriodicTimers` for details.
      def _setup_declarative_notifcation_timer(notification, interval)
        return if _stubbed_connection? ||
          @_declarative_notifications_timers.include?(notification)

        callback = proc do
          synchronize_entrypoint! do
            _handle_declarative_notifcation(notification)
          end
        end

        timer = start_periodic_timer(callback, every: interval)

        @_declarative_notifications_timers[notification] = timer
        active_periodic_timers << timer
      end

      def _stubbed_connection?
        defined?(ActionCable::Channel::ConnectionStub) &&
          connection.is_a?(ActionCable::Channel::ConnectionStub)
      end

      def _shutdown_declarative_notifcation_timer(notification, *)
        timer = @_declarative_notifications_timers.delete(notification)
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
