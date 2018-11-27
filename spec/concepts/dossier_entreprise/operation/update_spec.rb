require 'rails_helper'

describe DossierEntreprise::Operation::Update do
  let(:data) do
    {
      code_greffe: '1234',
      numero_gestion: '1A2B3C',
      siren: '123456789',
      date_immatriculation: 'hier',
      date_transfert: 'demain',
      sans_activite: 'OUI',
      date_debut_activite: 'A PAS ACTIVITE',
    }
  end

  subject { described_class.call(data: data) }

  context 'when the dossier is not found' do
    # TODO https://github.com/etalab/rncs_worker_api_entreprise/issues/36
    context 'with no existing dossier found for the given siren number' do
      it 'creates a new dossier' do
        all_dossiers_for_greffe = DossierEntreprise.where(code_greffe: data[:code_greffe])

        expect { subject }.to change(all_dossiers_for_greffe, :count).by(1)
      end

      it 'returns a warning message' do
        warning_msg = subject[:warning]

        expect(warning_msg).to eq('Dossier (numero_gestion: 1A2B3C) not found and no dossier with the siren number 123456789 exist for greffe 1234. Creating new dossier.')
      end

      it { is_expected.to be_success }
    end

    # TODO What to do when multiple dossiers are found for a given siren
    # TODO https://github.com/etalab/rncs_worker_api_entreprise/issues/41
    context 'when a dossier already exists for the given siren' do
      before do
        create(
          :dossier_entreprise,
          numero_gestion: '123ZZZ',
          code_greffe: data[:code_greffe],
          siren: data[:siren]
        )
      end

      #it 'creates a new dossier' do
      #  all_dossiers_for_greffe = DossierEntreprise.where(code_greffe: data[:code_greffe])

      #  expect { subject }.to change(all_dossiers_for_greffe, :count).by(1)
      #end

      it 'has now two differents dossiers for the same siren number' do
        subject
        all_dossiers_for_siren = DossierEntreprise.where(code_greffe: data[:code_greffe], siren: data[:siren])

        expect(all_dossiers_for_siren.size).to eq(2)
      end

      it 'returns a warning message' do
        warning_msg = subject[:warning]

        expect(warning_msg).to eq('Dossier (numero_gestion: 1A2B3C) not found for greffe 1234, but an existing dossier (numero_gestion: 123ZZZ) is found for siren 123456789 : a new dossier is created besides the existing one.')
      end

      it { is_expected.to be_success }
    end
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

    it 'does not return any warning message' do
      warning_msg = subject[:warning]

      expect(warning_msg).to be_nil
    end
  end
end
