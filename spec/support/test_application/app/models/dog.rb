# frozen_string_literal: true

class Dog < ApplicationRecord
  has_many :toys, dependent: :destroy

  validates :name, uniqueness: true, presence: true

  after_commit :broadcast_created!, on: :create

  accepts_nested_attributes_for :toys

  private

  def broadcast_created!
    ActionCable.server.broadcast("dogs:created", id)
  end
end
