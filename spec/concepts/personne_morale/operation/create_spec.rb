require 'rails_helper'

describe PersonneMorale::Operation::Create do
  subject { described_class.call(data: pm_data) }

  context 'when the related dossier entreprise exists' do
    let(:pm_data) do
      {
        code_greffe: '0109',
        numero_gestion: '2016A10937',
        denomination: 'Entreprise Test',
        forme_juridique: 'SAS',
      }
    end
    let(:created_pm) { subject[:created_pm] }
    before { create(:dossier_entreprise, code_greffe: '0109', numero_gestion: '2016A10937') }

    it { is_expected.to be_success }

    it 'saves the personne morale' do
      expect { subject }.to change(PersonneMorale, :count).by(1)
      expect(created_pm).to have_attributes(
        code_greffe: '0109',
        numero_gestion: '2016A10937',
        denomination: 'Entreprise Test',
        forme_juridique: 'SAS',
      )
    end

    it 'links the personne morale to the dossier entreprise' do
      dossier = DossierEntreprise.find_by(code_greffe: '0109', numero_gestion: '2016A10937')

      expect(created_pm.dossier_entreprise).to eq(dossier)
    end
  end

  # This should never happened since dossiers entreprises and personnes morales
  # share the same CSV file
  context 'when the related dossier entreprise is not found' do

  end
end
