require 'rails_helper'

# TODO: delegate theses checks and missings ones to new operation !
describe API::PdfController, type: :controller do
  subject do
    get :show, params: { siren: siren }
  end

  describe 'when siren invalid' do
    let(:siren) { invalid_siren }

    its(:status) { is_expected.to eq 400 }
  end

  describe 'non existent siren' do
    let(:siren) { non_existent_siren }

    its(:status) { is_expected.to eq 404 }
  end

  describe 'valid siren' do
    before { create :dossier_entreprise_simple, siren: siren }

    let(:siren) { valid_siren }

    its(:status) { is_expected.to eq 200 }

    it 'has a binary PDF body' do
      mime = MimeMagic.by_magic(subject.body)
      expect(mime.child_of?('application/pdf')).to be_truthy
    end
  end
end
