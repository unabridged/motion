# frozen_string_literal: true

class TestComponentsController < ApplicationController
  def show
    render_component_in_layout(TestComponent.new)
  end
end
