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

  task :javascript do
    sh "bin/yarn test"
  end
end

task :test do
  if ENV["TRAVIS"]
    Rake::Task["test:local"].invoke
  else
    Rake::Task["test:all"].invoke
  end

  Rake::Task["test:javascript"].invoke
end

namespace :lint do
  task :javascript do
    if ENV["TRAVIS"]
      sh "bin/yarn lint"
    else
      sh "bin/yarn lint --fix"
    end
  end
end

task :lint do
  if ENV["TRAVIS"]
    sh "bin/standardrb"
  else
    sh "bin/standardrb --fix"
  end

  Rake::Task["lint:javascript"].invoke
end

task default: %i[lint test]
