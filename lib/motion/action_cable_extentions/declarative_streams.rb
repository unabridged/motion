# frozen_string_literal: true

require "motion"

module Motion
  module ActionCableExtentions
    # Provides a `streaming_from(broadcasts, to:)` API that can be used to
    # declaratively specify what `broadcasts` the channel is interested in
    # receiving and `to` what method they should be routed.
    module DeclarativeStreams
      include Synchronization

      def initialize(*)
        super

        # Streams that we are currently interested in
        @_declarative_streams = Set.new

        # The method we are currently routing those streams to
        @_declarative_stream_target = nil

        # Streams that we are setup to listen to. Sadly, there is no public API
        # to stop streaming so this will only grow.
        @_declarative_stream_proxies = Set.new
      end

      # Clean up declarative streams when all streams are stopped.
      def stop_all_streams
        super

        @_declarative_streams.clear
        @_declarative_stream_target = nil

        @_declarative_stream_proxies.clear
      end

      # Declaratively routes provided broadcasts to the provided method.
      def streaming_from(broadcasts, to:)
        @_declarative_streams.replace(broadcasts)
        @_declarative_stream_target = to

        @_declarative_streams.each(&method(:_ensure_declarative_stream_proxy))
      end

      def declarative_stream_target
        @_declarative_stream_target
      end

      private

      def _ensure_declarative_stream_proxy(broadcast)
        return unless @_declarative_stream_proxies.add?(broadcast)

        # TODO: I feel like the fact that we have to specify the coder here is
        # a bug in ActionCable. It should be the default for this karg.
        stream_from(broadcast, coder: ActiveSupport::JSON) do |message|
          synchronize_entrypoint! do
            _handle_incoming_broadcast_to_declarative_stream(broadcast, message)
          end
        end
      end

      def _handle_incoming_broadcast_to_declarative_stream(broadcast, message)
        return unless @_declarative_stream_target &&
          @_declarative_streams.include?(broadcast)

        send(@_declarative_stream_target, broadcast, message)
      end
    end
  end
end
