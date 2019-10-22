require 'rails_helper'

describe Representant::Operation::Create do
  let(:rep_data) do
    {
      code_greffe:    '9001',
      numero_gestion: '2016A10937',
      qualite:        'Bullshit analyst',
      prenoms:        'Jean Peuplu'
    }
  end

  subject { described_class.call(data: rep_data) }

  context 'when associated dossier entreprise exists' do
    let(:created_rep) { subject[:created_rep] }

    before { create(:dossier_entreprise, code_greffe: '9001', numero_gestion: '2016A10937') }

    it { is_expected.to be_success }

    it 'saves the representant' do
      expect(created_rep).to be_persisted
      expect(created_rep).to have_attributes(
        code_greffe:    '9001',
        numero_gestion: '2016A10937',
        qualite:        'Bullshit analyst',
        prenoms:        'Jean Peuplu'
      )
    end

    it 'associates the representant to the correct dossier' do
      dossier = DossierEntreprise.find_by(code_greffe: '9001', numero_gestion: '2016A10937')

      expect(created_rep.dossier_entreprise).to eq(dossier)
    end
  end

  context 'when associated dossier entreprise is not found' do
    it_behaves_like 'related dossier not found'
  end
end
