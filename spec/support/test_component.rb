# frozen_string_literal: true

require "view_component"
require "motion"

class TestComponent < ViewComponent::Base
  include Motion::Component

  # used by tests that want to know the initial motions
  STATIC_MOTIONS = %w[
    noop
    noop_with_arg
    noop_without_arg
    change_state
    force_rerender
    setup_dynamic_motion
    setup_dynamic_stream
    raise_error
    raise_exception
  ].freeze

  # used by tests that want to know the initial broadcasts
  STATIC_BROADCASTS = %w[
    noop
    noop_with_arg
    noop_without_arg
    change_state
    force_rerender
    setup_dynamic_motion
    setup_dynamic_stream
    raise_error
    raise_exception
  ].freeze

  attr_reader :count

  def initialize(connected: :noop, disconnected: :noop, count: 0)
    @connected = connected
    @disconnected = disconnected

    @count = count
  end

  def call
    content_tag(:div) do
      safe_join(
        [
          content_tag(:div) { "The state has been changed #{@count} times." },
          *STATIC_MOTIONS.map do |motion|
            content_tag(:div) do
              content_tag(:button, motion, data: {motion: motion})
            end
          end
        ]
      )
    end
  end

  def connected
    public_send(@connected)
  end

  def disconnected
    public_send(@disconnected)
  end

  stream_from "noop", :noop
  map_motion :noop

  def noop(*)
  end

  stream_from "noop_with_arg", :noop_with_arg
  map_motion :noop_with_arg

  def noop_with_arg(_event_or_message)
  end

  stream_from "noop_without_arg", :noop_without_arg
  map_motion :noop_without_arg

  def noop_without_arg
  end

  stream_from "change_state", :change_state
  map_motion :change_state

  def change_state(*)
    @count += 1
  end

  stream_from "force_rerender", :force_rerender
  map_motion :force_rerender

  def force_rerender(*)
    rerender!
  end

  stream_from "setup_dynamic_motion", :setup_dynamic_motion
  map_motion :setup_dynamic_motion

  # used for tests that want to detect this dynamic motion being setup
  DYNAMIC_MOTION = "dynamic_motion"

  def setup_dynamic_motion(*)
    map_motion DYNAMIC_MOTION, :noop
  end

  stream_from "setup_dynamic_stream", :setup_dynamic_stream
  map_motion :setup_dynamic_stream

  # used for tests that want to detect this dynamic broadcast being setup
  DYNAMIC_BROADCAST = "dynamic_broadcast"

  def setup_dynamic_stream(*)
    stream_from DYNAMIC_BROADCAST, :noop
  end

  stream_from "raise_error", :raise_error
  map_motion :raise_error

  def raise_error(*)
    raise "Error from TestComponent"
  end

  stream_from "raise_exception", :raise_exception
  map_motion :raise_exception

  def raise_exception(*)
    raise Exception, # rubocop:disable Lint/RaiseException
      "Exception from TestComponent"
  end
end
