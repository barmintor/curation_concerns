require 'spec_helper'

describe IngestFileJob do
  let(:file_set) { create(:file_set) }
  let(:filename) { fixture_file_path('/world.png') }
  let(:user)     { create(:user) }

  it 'uses the provided mime_type' do
    described_class.perform_now(file_set.id, filename, 'image/png', 'bob')
    expect(file_set.reload.original_file.mime_type).to eq 'image/png'
  end

  context 'with two existing versions from different users' do
    let(:file1)    { fixture_file_path 'world.png' }
    let(:file2)    { fixture_file_path 'small_file.txt' }
    let(:versions) { file_set.reload.original_file.versions }
    let(:user2)     { create(:user) }

    before do
      described_class.perform_now(file_set.id, file1, 'image/png', user.user_key)
      described_class.perform_now(file_set.id, file2, 'text/plain', user2.user_key)
    end

    it 'has two versions' do
      expect(versions.all.count).to eq 2

      # the current version
      expect(CurationConcerns::VersioningService.latest_version_of(file_set.reload.original_file).label).to eq 'version2'
      expect(file_set.original_file.content).to eq File.open(file2).read
      expect(file_set.original_file.mime_type).to eq 'text/plain'
      expect(file_set.original_file.original_name).to eq 'small_file.txt'

      # the user for each version
      expect(VersionCommitter.where(version_id: versions.first.uri).pluck(:committer_login)).to eq [user.user_key]
      expect(VersionCommitter.where(version_id: versions.last.uri).pluck(:committer_login)).to eq [user2.user_key]
    end
  end

  describe "the after_create_contentcallback" do
    subject { CurationConcerns.config.callback }
    it 'runs with file_set and user arguments' do
      expect(subject).to receive(:run).with(:after_create_content, file_set, user)
      described_class.perform_now(file_set.id, filename, 'image/png', user.user_key)
    end
  end
end
