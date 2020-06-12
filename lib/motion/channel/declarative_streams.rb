# frozen_string_literal: true

require "motion"

module Motion
  class Channel < ApplicationCable::Channel
    module DeclarativeStreams
      # This is a list of all of the ways that ActionCable might call into the
      # channel *after* initialization.
      ACTION_CABLE_ENTRYPOINTS = %i[
        subscribe_to_channel
        unsubscribe_from_channel
        perform_action
      ].freeze

      private_constant :ACTION_CABLE_ENTRYPOINTS

      def initialize(*)
        super

        # Allowing actions to be bound to streams (as this module provides)
        # introduces the possibiliy of multiple threads accessing user code at
        # the same time. Protect user code with a Mutex so we only have to worry
        # about that here.
        @_declarative_stream_mutex = Mutex.new

        # Streams that we are currently interested in
        @_declarative_streams = Set.new

        # Streams that we are setup to listen to. Sadly, there is no public API
        # to stop streaming so this will only grow.
        @_declarative_stream_proxies = Set.new
      end

      # Guard the ActionCable entry points
      ACTION_CABLE_ENTRYPOINTS.each do |method|
        module_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{method}(*)
            @_declarative_stream_mutex.synchronize { super }
          end
        RUBY
      end

      private

      # Routes provided broadcasts to `#process_broadcast`
      def streaming_from(broadcasts)
        @_declarative_streams.replace(broadcasts)

        (@_declarative_streams - @_declarative_stream_proxies)
          .each(&method(:_setup_declarative_stream_proxy))
      end

      # Override in subclass
      def process_broadcast(_broadcast, _message)
      end

      def _setup_declarative_stream_proxy(broadcast)
        stream_from(broadcast) do |message|
          next unless @_declarative_streams.include?(broadcast)

          @_declarative_stream_mutex.synchronize do
            process_broadcast(broadcast, message)
          end
        end
      end
    end
  end
end
