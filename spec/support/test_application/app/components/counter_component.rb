# frozen_string_literal: true

class CounterComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :count, :child

  def initialize(count: 0)
    @count = count
    @child = nil
  end

  map_motion :increment

  def increment
    @count += 1
  end

  map_motion :decrement

  def decrement
    @count -= 1
  end

  map_motion :build_child

  def build_child
    @child = CounterComponent.new(count: count)
  end

  map_motion :clear_child

  def clear_child
    @child = nil
  end
end
