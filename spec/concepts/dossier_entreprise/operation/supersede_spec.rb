require 'rails_helper'

describe DossierEntreprise::Operation::Supersede do
  let(:data) do
    {
      code_greffe: '1234',
      numero_gestion: '1A2B3C',
      siren: '123456789',
      date_immatriculation: 'today',
      sans_activite: 'OUI',
      date_debut_activite: 'A PAS ACTIVITE'
    }
  end

  subject { described_class.call(data: data) }

  context 'when the dossier exists in database' do
    let(:old_dossier) do
      create(
        :dossier_entreprise,
        code_greffe: '1234',
        numero_gestion: '1A2B3C',
        siren: '123456789',
        date_immatriculation: 'hier',
        sans_activite: 'NON'
      )
    end

    before { old_dossier }

    it { is_expected.to be_success }

    it 'destroy the old dossier' do
      ghost = old_dossier
      subject

      expect { ghost.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'saves the new one' do
      subject
      dossier = DossierEntreprise.find_by(code_greffe: '1234', numero_gestion: '1A2B3C')

      expect(dossier).to be_persisted
      expect(dossier.date_immatriculation).to eq('today')
      expect(dossier.sans_activite).to eq('OUI')
    end
  end

  context 'when the dossier is not save in database' do
    it { is_expected.to be_success }

    it 'saves the new one' do
      subject
      dossier = DossierEntreprise.find_by(code_greffe: '1234', numero_gestion: '1A2B3C')

      expect(dossier).to be_persisted
      expect(dossier.date_immatriculation).to eq('today')
      expect(dossier.sans_activite).to eq('OUI')
    end
  end
end
