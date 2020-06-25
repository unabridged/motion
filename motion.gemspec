# frozen_string_literal: true

require_relative "lib/motion/version"

Gem::Specification.new do |spec|
  spec.name = "motion"
  spec.version = Motion::VERSION
  spec.authors = ["Alec Larsen", "Drew Ulmer"]
  spec.email = ["alec@unabridgedsoftware.com", "drew@unabridgedsoftware.com"]

  spec.summary = "Reactive view components written in Ruby for Rails"
  spec.description = <<~TEXT
    Motion extends Github's `view_component` gem with reactivity to interactions
    from the user and broadcasts on the server.
  TEXT

  spec.license = "MIT"
  spec.homepage = "https://github.com/unabridged/motion"

  spec.metadata = {
    "bug_tracker_uri" => spec.homepage,
    "source_code_uri" => spec.homepage
  }

  spec.files = Dir["lib/**/*"]
  spec.require_paths = ["lib"]

  # Required for the squiggly HEREDOC
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.add_dependency "nokogiri"
  spec.add_dependency "rails", ">= 5.2"

  spec.post_install_message = <<~MSG
    Friendly reminder: When updating the motion gem, don't forget to update the
    NPM package as well (`bin/yarn add '@unabridged/motion@#{spec.version}'`).
  MSG
end
