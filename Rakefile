# frozen_string_literal: true

require "bundler/gem_tasks"

namespace :test do
  task :local do
    sh "bin/rspec"
  end

  task :all do
    sh "bin/appraisal install"
    sh "bin/appraisal bin/rake test:local"
  end
end

task :test do
  if ENV["TRAVIS"]
    Rake::Task["test:local"].invoke
  else
    Rake::Task["test:all"].invoke
  end
end

task :lint do
  if ENV["TRAVIS"]
    sh "bin/standardrb --no-fix"
  else
    sh "bin/standardrb"
  end
end

task default: %i[lint test]
