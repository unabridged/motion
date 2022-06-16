# frozen_string_literal: true

class CheckboxComponentsController < ApplicationController
  def show
    render_component_in_layout(CheckboxComponent.new)
  end
end
