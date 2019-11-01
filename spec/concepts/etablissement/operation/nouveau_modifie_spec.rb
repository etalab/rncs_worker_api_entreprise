require 'rails_helper'

describe Etablissement::Operation::NouveauModifie do
  let(:data) do
    {
      code_greffe: '1234',
      numero_gestion: '1A2B3C',
      id_etablissement: '1',
      nom_commercial: 'GG EASY',
      enseigne: 'YOU SALTY',
    }
  end

  subject { described_class.call(data: data) }

  context 'when the dossier exists' do
    let(:dossier) do
      create(
        :dossier_entreprise,
        code_greffe: '1234',
        numero_gestion: '1A2B3C',
      )
    end

    context 'when the etablissement exists' do
      before do
        create(:etablissement, id_etablissement: '1', dossier_entreprise: dossier)
      end

      it { is_expected.to be_success }

      it 'updates the etablissement' do
        subject
        updated_ets = dossier.etablissements.find_by(id_etablissement: '1')

        expect(updated_ets).to have_attributes(
          nom_commercial: 'GG EASY',
          enseigne: 'YOU SALTY',
        )
      end
    end

    context 'when the etablissement does not exist' do
      before { dossier }

      it 'creates a new etablissement associated with the dossier' do
        expect { subject }.to change(dossier.etablissements, :count).by(1)
      end

      it 'returns a warning message' do
        warning_msg = subject[:warning]

        expect(warning_msg).to eq('The etablissement (id_etablissement: 1) was not found in dossier (code_greffe: 1234, numero_gestion: 1A2B3C) for update. Created instead.')
      end

      it { is_expected.to be_success }
    end
  end

  # TODO https://github.com/etalab/rncs_worker_api_entreprise/issues/39
  context 'when the related dossier is not found' do
    it 'returns a warning message' do
      warning_msg = subject[:warning]

      expect(warning_msg).to eq("The dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}) is not found. The etablissement (id_etablissement: #{data[:id_etablissement]}) is not imported.")
    end

    it { is_expected.to be_success }
  end
end
