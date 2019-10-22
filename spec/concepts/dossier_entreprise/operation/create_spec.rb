require 'rails_helper'

describe DossierEntreprise::Operation::Create do
  let(:data) do
    {
      code_greffe:      '2288',
      numero_gestion:   '1A2B3C',
      siren:            '111222333',
      type_inscription: 'Very P',
      sans_activite:    'OUI'
    }
  end

  subject { described_class.call(data: data) }

  context 'when the dossier already exists' do
    let(:existing_dossier) { create(:dossier_entreprise, code_greffe: data[:code_greffe], numero_gestion: data[:numero_gestion]) }

    before { existing_dossier }

    it { is_expected.to be_success }

    it 'returns a warning message' do
      warning_msg = subject[:warning]

      expect(warning_msg).to eq('The dossier (code_greffe: 2288, numero_gestion: 1A2B3C) already exists in database and is overriden.')
    end

    it 'destroys the old dossier' do
      subject

      expect { existing_dossier.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'saves the new one' do
      subject
      new_dossier = DossierEntreprise.find_by(code_greffe: data[:code_greffe], numero_gestion: data[:numero_gestion])

      expect(new_dossier).to have_attributes(
        siren:            '111222333',
        type_inscription: 'Very P',
        sans_activite:    'OUI'
      )
    end
  end

  context 'when the dossier does not exist' do
    it { is_expected.to be_success }

    it 'creates the new dossier' do
      expect { subject }.to change(DossierEntreprise, :count).by(1)
    end
  end
end
