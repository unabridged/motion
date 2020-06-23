# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  add_filter "/bin/"
  add_filter "/spec/"
end