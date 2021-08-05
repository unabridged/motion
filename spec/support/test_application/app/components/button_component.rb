# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :text, :on_click

  serializes :text, :on_click

  def initialize(text:, on_click:)
    @text = text
    @on_click = on_click
  end

  map_motion :click

  def click
    on_click.call
  end
end
