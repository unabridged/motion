# frozen_string_literal: true

class CallbackComponentsController < ApplicationController
  def show
    render_component_in_layout(CallbackComponent.new)
  end
end
