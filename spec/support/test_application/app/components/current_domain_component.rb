# frozen_string_literal: true

class CurrentDomainComponent < ViewComponent::Base
    include Motion::Component
  
    attr_reader :num_ticks
  
    def initialize
      @num_ticks = 0
    end
  
    every 5.seconds, :tick
  
    def tick
      @num_ticks += 1
    end
  end