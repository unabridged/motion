# frozen_string_literal: true

class Toy < ApplicationRecord
  belongs_to :dog

  validates :name, presence: true
end
