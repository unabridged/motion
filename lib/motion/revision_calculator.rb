# frozen_string_literal: true

require "digest"
require "motion"

module Motion
  class RevisionCalculator
    attr_reader :revision_paths

    def initialize(revision_paths:)
      @revision_paths = revision_paths
    end

    def perform
      derive_md5_hash
    end

    private

    def existent_paths
      @existent_paths ||= revision_paths.all_paths.flat_map(&:existent)
    end

    def files
      @files ||= existent_paths.flat_map { |path| Dir["#{path}/**/*", path].reject { |f| File.directory?(f) } }.uniq
    end

    def derive_md5_hash
      digest = Digest::MD5.new

      files.each do |file|
        digest << File.read(file)
      end

      digest.hexdigest
    end
  end
end
