require 'rails_helper'

describe Observation::Operation::UpdateOrCreate do
  let(:data) do
    {
      code_greffe: '9001',
      numero_gestion: '2016A10937',
      id_observation: '4000',
      numero: '12A57',
      texte: 'I can see you',
    }
  end

  subject { described_class.call(data: data) }

  context 'when associated dossier entreprise exists' do
    let(:dossier) do
      create(
        :dossier_entreprise,
        code_greffe: data[:code_greffe],
        numero_gestion: data[:numero_gestion],
      )
    end

    before { dossier }

    context 'when the observation exists in database' do
      before { create(:observation, id_observation: data[:id_observation], dossier_entreprise: dossier) }

      it 'is updated' do
        subject
        updated_obs = dossier.observations.find_by(id_observation: '4000')

        expect(updated_obs).to have_attributes(
          id_observation: '4000',
          numero: '12A57',
          texte: 'I can see you',
        )
      end

      it 'is deleted if etat: "Supression"' do
        data[:etat] = 'Suppression'

        expect { subject }.to change(dossier.observations, :count).by(-1)
        expect(subject).to be_success
      end

      it { is_expected.to be_success }
    end

    context 'when the observation does not exists' do
      it 'does nothing if etat: "Suppression"' do
        data[:etat] = 'Suppression'

        expect { subject }.to_not change(dossier.observations, :count)
        expect(subject).to be_success
      end

      it 'is created for the related dossier' do
        expect { subject }.to change(dossier.observations, :count).by(1)
      end

      it { is_expected.to be_success }
    end
  end

  # TODO https://github.com/etalab/rncs_worker_api_entreprise/issues/35
  context 'when associated dossier entreprise is not found' do
    it 'returns a warning message' do
      warning_msg = subject[:warning]

      expect(warning_msg).to eq("The dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}) is not found. The observation with ID: #{data[:id_observation]} is not imported.")
    end

    it { is_expected.to be_success }
  end
end
