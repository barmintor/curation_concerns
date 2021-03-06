require 'spec_helper'

describe 'curation_concerns/single_use_links/new_download.html.erb' do
  let(:user) { create(:user) }

  let(:f) do
    file = FileSet.create do |gf|
      gf.apply_depositor_metadata(user)
    end
    Hydra::Works::AddFileToFileSet.call(file, File.open(fixture_path + '/world.png'), :original_file)
    file
  end

  let(:hash) { "some-dummy-sha2-hash" }

  before do
    assign :asset, f
    assign :link, CurationConcerns::Engine.routes.url_helpers.download_single_use_link_path(hash)
    render
  end

  it "has the download link" do
    expect(rendered).to have_selector "a.download-link"
  end

  it "has turbolinks disabled in the download link" do
    expect(rendered).to have_selector "a.download-link[data-no-turbolink]"
  end
end
