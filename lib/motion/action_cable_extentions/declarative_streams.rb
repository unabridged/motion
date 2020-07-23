# frozen_string_literal: true

require "motion"

module Motion
  module ActionCableExtentions
    # This module provides an API to setup a method to be called for certain
    # broadcasts. It differes from ActionCable's built-in +stream_from+ in that
    # a single method is called for all broadcasts. This scheme avoids the need
    # for any dynamic blocks which could not be +Marshal.dump+'d.
    #
    # @api private
    module DeclarativeStreams
      include Synchronization

      # Configures a method (+to+) to be called a whenever particular broadcasts
      # (+broadcasts+) are received. As the module name suggests, this method is
      # "declarative" in that it will replace all existing broadcasts with the
      # broadcasts provided.
      #
      # @param broadcasts [Array<String>]
      #   the broadcasts that the channel is interested in receiving
      #
      # @param to [Symbol]
      #   the method to which the broadcasts should be delivered
      def streaming_from(broadcasts, to:)
        @_declarative_streams.replace(broadcasts)
        @_declarative_stream_target = to

        @_declarative_streams.each(&method(:_ensure_declarative_stream_proxy))
      end

      # @return [Array<String>]
      #   the current broadcasts
      #
      # @note
      #   This matches the +broadcasts+ argument of the last call to
      #   {#streaming_from}.
      def declarative_streams
        @_declarative_streams
      end

      # @return [Symbol]
      #   the current method to which broadcasts are being delivered
      #
      # @note
      #   This matches the +to+ argument of the last call to {#streaming_from}.
      def declarative_stream_target
        @_declarative_stream_target
      end

      # This method is called by ActionCable when all streams should be removed.
      #
      # @private
      def stop_all_streams
        super

        @_declarative_streams.clear
        @_declarative_stream_target = nil

        @_declarative_stream_proxies.clear
      end

      private

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
