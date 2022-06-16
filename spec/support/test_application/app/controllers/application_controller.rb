# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  # Rendering the component inline like this causes the application layout to
  # be used (when rendering directly, this does not happen for some reason).
  def render_component_in_layout(component)
    render inline: "<%= render component %>",
      locals: {component: component},
      layout: true
  end
end
