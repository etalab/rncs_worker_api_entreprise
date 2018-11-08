require 'rails_helper'

describe DossierEntreprise::Operation::Update do
  let(:data) do
    {
      code_greffe: '1234',
      numero_gestion: '1A2B3C',
      date_immatriculation: 'hier',
      date_transfert: 'demain',
      sans_activite: 'OUI',
      date_debut_activite: 'A PAS ACTIVITE',
    }
  end

  subject { described_class.call(data: data) }

  context 'when the dossier is not found' do
    it_behaves_like 'related dossier not found'
  end

  context 'when the dossier is found' do
    before do
      create(
        :dossier_entreprise,
        code_greffe: data[:code_greffe],
        numero_gestion: data[:numero_gestion],
      )
    end

    it { is_expected.to be_success }

    it 'updates the given fields' do
      subject
      updated_dossier = DossierEntreprise.find_by(code_greffe: data[:code_greffe], numero_gestion: data[:numero_gestion])

      expect(updated_dossier).to have_attributes(
        date_immatriculation: 'hier',
        date_transfert: 'demain',
        sans_activite: 'OUI',
        date_debut_activite: 'A PAS ACTIVITE'
      )
    end
  end
end
