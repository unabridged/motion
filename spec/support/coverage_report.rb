# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  add_filter "/bin/"
  add_filter "/spec/"
end

# TODO: Update this to branch coverge when we upgrade to v0.18
# https://github.com/colszowka/simplecov#minimum-coverage
SimpleCov.minimum_coverage(80)
