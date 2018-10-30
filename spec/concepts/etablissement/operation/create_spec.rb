require 'rails_helper'

describe Etablissement::Operation::Create do
  let(:ets_data) do
    {
      code_greffe: '9001',
      numero_gestion: '2016A10937',
      enseigne: 'Very office',
      nom_commercial: 'Much Building',
    }
  end

  subject { described_class.call(data: ets_data) }

  context 'when associated dossier entreprise exists' do
    let(:created_ets) { subject[:created_ets] }

    before { create(:dossier_entreprise, code_greffe: '9001', numero_gestion: '2016A10937') }

    it { is_expected.to be_success }

    it 'saves the etablissement' do
      expect(created_ets).to be_persisted
      expect(created_ets).to have_attributes(
        code_greffe: '9001',
        numero_gestion: '2016A10937',
        enseigne: 'Very office',
        nom_commercial: 'Much Building',
      )
    end

    it 'associates the etablissement to the correct dossier' do
      dossier = DossierEntreprise.find_by(code_greffe: '9001', numero_gestion: '2016A10937')

      expect(created_ets.dossier_entreprise).to eq(dossier)
    end
  end

  context 'when associated dossier entreprise is not found' do
    it_behaves_like 'related dossier not found'
  end
end
