require 'rails_helper'

describe Entreprise::Operation::Identity do
  subject { described_class.call(siren: siren) }
  let(:http_error) { subject[:http_error] }

  context 'with an invalid siren' do
    let(:siren) { invalid_siren }

    it { is_expected.to be_failure }

    it 'returns a 422 error' do
      expect(http_error[:code]).to eq(422)
      expect(http_error[:message]).to eq('Siren invalide')
    end
  end

  context 'when no dossiers are found' do
    let(:siren) { valid_siren }

    it { is_expected.to be_failure }

    it 'sets a 404 http error' do
      expect(http_error[:code]).to eq(404)
      expect(http_error[:message]).to eq('Aucun dossier trouvé.')
    end
  end

  context 'with no exclusif dossier principal' do
    let(:siren) { valid_siren }

    shared_examples 'no exclusif dossier principal' do
      it { is_expected.to be_failure }

      it 'returns a 500 error' do
        expect(http_error[:code]).to eq(500)
        expect(http_error[:message]).to match(/\A\d+ dossiers principaux trouvés\Z/)
      end
    end

    context 'with 0 dossier principal' do
      before { create(:dossier_entreprise, type_inscription: 'S', siren: siren) }

      it_behaves_like 'no exclusif dossier principal'
    end

    context 'with 2 dossier principal' do
      before { create_list(:dossier_entreprise, 3, type_inscription: 'S', siren: siren) }
      it_behaves_like 'no exclusif dossier principal'
    end
  end

  context 'with one and only one dossier principal' do
    let(:siren) { valid_siren }
    before { create(:dossier_entreprise, type_inscription: 'P', siren: siren) }

    context 'when an etablissement principal is found in this dossier' do
      before do
        dossier = DossierEntreprise.find_by(siren: siren)
        create(:etablissement_principal, dossier_entreprise: dossier)
      end

      it { is_expected.to be_success }

      describe 'collected data' do
        let(:entreprise_identity) { subject[:entreprise_identity] }
        # TODO
      end
    end

    context 'when no etablissement principal is found' do
      it { is_expected.to be_failure }

      it 'returns a 500 error' do
        expect(http_error[:code]).to eq(500)
        expect(http_error[:message]).to eq('Aucun etablissement principal trouvé dans le dossier principal')
      end
    end
  end
end

