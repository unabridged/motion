# frozen_string_literal: true

require "bundler/gem_tasks"

namespace :test do
  task :all do
    sh "bin/appraisal install"
    sh "bin/appraisal bin/rake test"
  end
end

task :test do
  sh "bin/rspec"
  sh "bin/yarn test"
end

task :lint do
  if ENV["TRAVIS"]
    sh "bin/standardrb"
    sh "bin/yarn lint"
  else
    sh "bin/standardrb --fix"
    sh "bin/yarn lint --fix"
  end
end

task default: %i[lint test]
