# frozen_string_literal: true

class TimerComponentsController < ApplicationController
  def show
    render_component_in_layout(TimerComponent.new)
  end
end
