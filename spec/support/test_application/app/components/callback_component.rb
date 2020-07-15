# frozen_string_literal: true

class CallbackComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :count

  def initialize(count: 0)
    @count = count
  end

  def increment
    @count += 1
  end
end
