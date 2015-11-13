require 'spec_helper'

describe CurationConcerns::Forms::WorkForm do
  before do
    class PirateShip < ActiveFedora::Base
      include CurationConcerns::BasicMetadata
      include CurationConcerns::HasRepresentative
    end

    class PirateShipForm < described_class
      self.model_class = ::PirateShip
    end
  end

  after do
    Object.send(:remove_const, :PirateShipForm)
    Object.send(:remove_const, :PirateShip)
  end

  let(:curation_concern) { create(:work_with_one_file) }
  let(:title) { curation_concern.file_sets.first.title.first }
  let(:file_id) { curation_concern.file_sets.first.id }
  let(:ability) { nil }
  let(:form) { PirateShipForm.new(curation_concern, ability) }

  describe "#select_files" do
    subject { form.select_files }
    it { is_expected.to eq(title => file_id) }
  end

  describe "#[]" do
    it 'has one element' do
      expect(form['description']).to eq ['']
    end
  end

  describe '.model_attributes' do
    let(:params) { ActionController::Parameters.new(
      title: ['foo'],
      description: [''],
      visibility: 'open',
      admin_set_id: '123',
      representative_id: '456',
      thumbnail_id: '789',
      rights: 'http://creativecommons.org/licenses/by/3.0/us/')
    }
    subject { PirateShipForm.model_attributes(params) }

    it 'permits parameters' do
      expect(subject['title']).to eq ['foo']
      expect(subject['description']).to be_empty
      expect(subject['visibility']).to eq 'open'
      expect(subject['rights']).to eq ['http://creativecommons.org/licenses/by/3.0/us/']
    end

    it 'excludes non-permitted params' do
      expect(subject).not_to have_key 'admin_set_id'
    end
  end
end
