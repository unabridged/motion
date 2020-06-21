# frozen_string_literal: true

class CounterComponentsController < ApplicationController
  def show
    render_component_in_layout(CounterComponent.new)
  end
end
