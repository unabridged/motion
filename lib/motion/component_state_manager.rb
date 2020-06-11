# frozen_string_literal: true

module Motion
  class StateManager
    def initialize(object:, hasher:)
      @mutex = Mutex.new
      @object = object
      @hasher = hasher
    end

    def use
      @mutex.synchronize do
        yield @object
      end
    end

    def flush
      @mutex.synchronize do
        while @hash != (next_hash = calculate_hash)
          yield @object
          @hash = next_hash
        end
      end
    end

    private

    def calculate_hash
      @hasher.call(@object)
    end
  end

  private_constant :StateManager

  class ComponentStateManager < StateManager
    def self.build_hasher(serializer)
      ->(component) { serializer.digest(component) }
    end

    def initialize(state:, serializer: Motion.serializer)
      super(
        object: serializer.deserialize(state),
        hasher: self.class.build_hasher(serializer)
      )
    end
  end
end
