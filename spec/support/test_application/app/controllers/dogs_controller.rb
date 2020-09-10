# frozen_string_literal: true

class DogsController < ApplicationController
  def new
    render_component_in_layout(DogFormComponent.new)
  end

  def create
    Dog.create!(dog_params)

    redirect_to(new_dog_path)
  end

  private

  def dog_params
    params.require(:dog).permit(:name, toys_attributes: [:id, :name])
  end
end
