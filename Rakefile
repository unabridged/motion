# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"

task default: %i[lint doc test]

namespace :test do
  task :refresh do
    sh "bin/appraisal clean"
    sh "bin/appraisal generate"
  end

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

namespace :doc do
  task :generate do
    sh "bin/yard doc --quiet"
  end

  task :verify do
    require "yardstick"

    next if (measurements = Yardstick.measure).coverage == 1

    measurements.puts
    raise "Some documentation is missing! Please add it."
  end
end

task :doc do
  Rake::Task["doc:generate"].invoke unless ENV["TRAVIS"]
  Rake::Task["doc:verify"].invoke
end

namespace :release do
  task :guard_version_match do
    require "json"

    package_version =
      JSON.parse(File.read("package.json")).fetch("version")

    next if Motion::VERSION == package_version

    raise "The package version and the gem version do not match!"
  end

  task :yarn_publish do
    sh "bin/yarn publish --new-version '#{Motion::VERSION}' --access public"
  end
end

# Remove Bundler's release task so we can add our own hooks
Rake::Task["release"].clear

task :release, %i[release] => %i[
  lint
  test:all
  build
  release:guard_clean
  release:guard_version_match
  release:source_control_push
  release:yarn_publish
  release:rubygem_push
]
