# frozen_string_literal: true

class TimerComponent < ViewComponent::Base
  include Motion::Component

  def initialize(seconds: 1)
    @seconds = seconds
  end

  every 1.second, :tick

  def tick
    @seconds -= 1

    stop_periodic_timer(:tick) if @seconds.zero?
  end

  def call
    content_tag(:div) { @seconds.to_s }
  end
end
