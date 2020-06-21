# frozen_string_literal: true

# Load the TestApplication environment into this Ruby process
require_relative "test_application/config/environment"

# Also, load the generators since some specs depend on those.
Rails.application.load_generators
