# frozen_string_literal: true

class DogFormComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :dog

  def initialize(dog: Dog.new)
    @dog = dog
  end

  stream_from "dogs:created", :handle_dog_created
  map_motion :validate

  def validate(event)
    dog.assign_attributes(event.form_data.require(:dog).permit(:name))
    dog.validate
  end

  def handle_dog_created(_new_id)
    dog.validate
  end
end
