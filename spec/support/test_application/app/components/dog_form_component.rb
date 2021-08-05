# frozen_string_literal: true

class DogFormComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :dog

  serializes :dog

  def initialize(dog: Dog.new)
    @dog = dog
  end

  map_motion :validate

  def validate(event)
    clear_unidentifiable_toys

    dog.assign_attributes(dog_params(event.form_data))
    dog.validate
  end

  map_motion :add_toy

  def add_toy
    dog.toys.build
  end

  stream_from "dogs:created", :handle_dog_created

  def handle_dog_created(_new_id)
    dog.validate
  end

  private

  # TODO: This is required because `accepts_nested_attributes_for` doesn't have
  # a way to identify unpersisted records which makes assignment non-idempotent.
  # It would be ideal to fix the problem there.
  def clear_unidentifiable_toys
    dog.toys.target&.select!(&:persisted?)
  end

  def dog_params(params)
    params.require(:dog).permit(:name, toys_attributes: [:id, :name])
  end
end
