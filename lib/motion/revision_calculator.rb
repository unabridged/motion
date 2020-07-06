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
      derive_file_hash
    end

    private

    def derive_file_hash
      digest = Digest::MD5.new

      files.each do |file|
        digest << file # include filename as well as contents
        digest << File.read(file)
      end

      digest.hexdigest
    end

    def existent_paths
      @existent_paths ||=
        begin
          revision_paths.all_paths.flat_map(&:existent)
        rescue
          raise BadRevisionPathsError
        end
    end

    def existent_files(path)
      Dir["#{path}/**/*", path].reject { |f| File.directory?(f) }.uniq
    end

    def files
      @files ||= existent_paths.flat_map { |path| existent_files(path) }.sort
    end
  end
end
