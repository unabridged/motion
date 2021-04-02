# frozen_string_literal: true

class CurrentDomainComponentsController < ApplicationController
    def show
      render_component_in_layout(CurrentDomainComponent.new)
    end
  end