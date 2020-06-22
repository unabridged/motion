# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "standard/rake"
require "appraisal/task"
require "json"

RSpec::Core::RakeTask.new(:spec)
Appraisal::Task.new

namespace :release do
  task :guard_version do
    next if Motion::VERSION == JSON.parse(File.read("./package.json")).fetch("version")

    raise "The NPM package version does not match the gem version."
  end

  task :npm_publish do
    sh "bin/yarn " \
      "publish " \
      "--cwd ./client " \
      "--new-version '#{Motion::VERSION}' " \
      "--access public"
  end
end

# Remove the default release task defined by Bundler
Rake::Task[:release].clear

task release: %i[
  build
  release:guard_version
  release:guard_clean
  release:source_control_push
  release:npm_publish
  release:rubygem_push
]

if !ENV["APPRAISAL_INITIALIZED"] && !ENV["TRAVIS"]
  task default: :appraisal
else
  task default: :spec
end
