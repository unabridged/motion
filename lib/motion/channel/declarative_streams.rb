# frozen_string_literal: true

require "motion"

module Motion
  class Channel < ApplicationCable::Channel
    module DeclarativeStreams
      def initialize(*)
        super

        # Allowing actions to be bound to streams (as this module provides)
        # introduces the possibiliy of multiple threads accessing user code at
        # the same time. Protect user code with a Monitor so we only have to
        # worry about that here.
        @_declarative_stream_monitor = Monitor.new

        # Streams that we are currently interested in
        @_declarative_streams = Set.new

        # The method we are currently routing those streams to
        @_declarative_stream_target = nil

        # Streams that we are setup to listen to. Sadly, there is no public API
        # to stop streaming so this will only grow.
        @_declarative_stream_proxies = Set.new
      end

      # Synchronize all ActionCable entry points (after initialization).
      def subscribe_to_channel(*)
        @_declarative_stream_monitor.synchronize { super }
      end

      def unsubscribe_from_channel(*)
        @_declarative_stream_monitor.synchronize { super }
      end

      def perform_action(*)
        @_declarative_stream_monitor.synchronize { super }
      end

      private

      # Declaratively routes provided broadcasts to the provided method.
      def streaming_from(broadcasts, to:)
        @_declarative_streams.replace(broadcasts)
        @_declarative_stream_target = to

        @_declarative_streams.each(&method(:_ensure_declarative_stream_proxy))
      end

      def stop_all_streams
        super

        @_declarative_streams.clear
        @_declarative_stream_target = nil

        @_declarative_stream_proxies.clear
      end

      def _ensure_declarative_stream_proxy(broadcast)
        return unless @_declarative_stream_proxies.add?(broadcast)

        stream_from(broadcast) do |message|
          next unless @_declarative_streams.include?(broadcast)

          @_declarative_stream_monitor.synchronize do
            send(@_declarative_stream_target, broadcast, message)
          end
        rescue Exception => e # rubocop:disable Lint/RescueException
          # It is very, very important that we do not allow an exception to
          # escape here as the internals of ActionCable will stop processing
          # the broadcast.

          logger.error(
            "There was an exception - #{e.class}(#{e.message})\n" +
            e.backtrace.join("\n")
          )
        end
      end
    end
  end
end
