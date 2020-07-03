# frozen_string_literal: true

RSpec.describe Motion::RevisionCalculator do
  subject(:calculator) do
    described_class.new(
      revision_paths: revision_paths
    )
  end

  let(:revision_paths) { Rails.application.config.paths.dup }

  describe "#perform" do
    subject(:output) { calculator.perform }
    let(:empty_hash) { Digest::MD5.new.hexdigest }

    context "when the revisions path is not a Rails::Paths::Root object" do
      let(:revision_paths) { [] }

      it "raises BadRevisionPathsError" do
        expect { subject }.to raise_error(Motion::BadRevisionPathsError)
      end
    end

    context "when there are no paths to hash" do
      let(:revision_paths) { Rails::Paths::Root.new(Rails.application.root) }
      let(:empty_hash) { Digest::MD5.new.hexdigest }

      it "hashes empty digest" do
        expect(subject).to eq(empty_hash)
      end
    end

    context "when paths do not exist" do
      let(:revision_paths) do
        paths = Rails::Paths::Root.new(Rails.application.root)
        paths.add "foo"
        paths
      end

      it "ignores empty directory" do
        expect(subject).to eq(empty_hash)
      end
    end

    context "for normal application with files" do
      let(:all_dirs) { revision_paths.all_paths.flat_map(&:existent) }
      let(:first_dir) { all_dirs.first }
      let(:new_file) { "#{first_dir}/foot.txt" }

      before(:each) { File.delete(new_file) if File.exist?(new_file) }
      after(:each) { File.delete(new_file) if File.exist?(new_file) }

      it "hashes contents" do
        expect(subject).not_to eq(empty_hash)
      end

      it "has files to hash" do
        assert all_dirs.length.positive?
      end

      it "changes contents when file contents change" do
        first_result = subject

        File.open(new_file, "w+") { |file| file.write("test") }
        second_calc = Motion::RevisionCalculator.new(revision_paths: revision_paths).perform
        expect(second_calc).not_to eq(first_result)
        expect(second_calc).not_to eq(empty_hash)
      end
    end
  end
end
