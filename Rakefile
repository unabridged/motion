# frozen_string_literal: true

require "bundler/gem_tasks"

task default: %i[lint test]

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
