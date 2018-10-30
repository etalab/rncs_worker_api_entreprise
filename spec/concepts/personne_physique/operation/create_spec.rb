require 'rails_helper'

describe PersonnePhysique::Operation::Create do
  subject { described_class.call(data: pp_data) }

  context 'when the related dossier entreprise exists' do
    let(:pp_data) do
      {
        code_greffe: '0109',
        numero_gestion: '2016A10937',
        nom_usage: 'Bon',
        prenoms: 'Jean',
      }
    end
    let(:created_pp) { subject[:created_pp] }
    before { create(:dossier_entreprise, code_greffe: '0109', numero_gestion: '2016A10937') }

    it { is_expected.to be_success }

    it 'saves the personne physique' do
      expect { subject }.to change(PersonnePhysique, :count).by(1)
      expect(created_pp).to have_attributes(
        code_greffe: '0109',
        numero_gestion: '2016A10937',
        nom_usage: 'Bon',
        prenoms: 'Jean',
      )
    end

    it 'links the personne physique to the dossier entreprise' do
      dossier = DossierEntreprise.find_by(code_greffe: '0109', numero_gestion: '2016A10937')

      expect(created_pp.dossier_entreprise).to eq(dossier)
    end
  end

  # This should never happened since dossiers entreprises and personnes physique
  # share the same CSV file
  context 'when the related dossier entreprise is not found' do

  end
end
