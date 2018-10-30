require 'rails_helper'

describe Observation::Operation::Create do
  let(:obs_data) do
    {
      code_greffe: '9001',
      numero_gestion: '2016A10937',
      numero: '12',
      texte: 'I can see you',
    }
  end

  subject { described_class.call(data: obs_data) }

  context 'when associated dossier entreprise exists' do
    let(:created_obs) { subject[:created_obs] }

    before { create(:dossier_entreprise, code_greffe: '9001', numero_gestion: '2016A10937') }

    it { is_expected.to be_success }

    it 'saves the observation' do
      expect(created_obs).to be_persisted
      expect(created_obs).to have_attributes(
        code_greffe: '9001',
        numero_gestion: '2016A10937',
        numero: '12',
        texte: 'I can see you',
      )
    end

    it 'associates the observation to the correct dossier' do
      dossier = DossierEntreprise.find_by(code_greffe: '9001', numero_gestion: '2016A10937')

      expect(created_obs.dossier_entreprise).to eq(dossier)
    end
  end

  context 'when associated dossier entreprise is not found' do
    it_behaves_like 'related dossier not found'
  end
end
