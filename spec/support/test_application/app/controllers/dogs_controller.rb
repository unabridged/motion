# frozen_string_literal: true

class DogsController < ApplicationController
  def new
    render_component_in_layout(DogFormComponent.new)
  end

  def create
    Dog.create!(params.require(:dog).permit(:name))

    redirect_to(new_dog_path)
  end
end
