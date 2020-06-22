# frozen_string_literal: true

class Dog < ApplicationRecord
  validates :name, uniqueness: true, presence: true

  after_commit :broadcast_created!, on: :create

  private

  def broadcast_created!
    ActionCable.server.broadcast("dogs:created", id)
  end
end
