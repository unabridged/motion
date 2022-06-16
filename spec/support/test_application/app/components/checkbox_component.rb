# frozen_string_literal: true

class CheckboxComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :checked
  alias_method :checked?, :checked

  def initialize
    @checked = false
  end

  map_motion :update_checked

  def update_checked(event)
    @checked = event.target.checked?
  end
end
