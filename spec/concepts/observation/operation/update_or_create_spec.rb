require 'rails_helper'

describe Observation::Operation::UpdateOrCreate do
  let(:obs_data) do
    {
      code_greffe: '9001',
      numero_gestion: '2016A10937',
      id_observation: '4000',
      numero: '12A57',
      texte: 'I can see you',
    }
  end

  subject { described_class.call(data: obs_data) }

  context 'when associated dossier entreprise exists' do
    let(:dossier) do
      create(
        :dossier_entreprise,
        code_greffe: obs_data[:code_greffe],
        numero_gestion: obs_data[:numero_gestion],
      )
    end

    before { dossier }

    context 'when the observation exists in database' do
      before { create(:observation, id_observation: obs_data[:id_observation], dossier_entreprise: dossier) }

      it 'is updated' do
        subject
        updated_obs = dossier.observations.find_by(id_observation: '4000')

        expect(updated_obs).to have_attributes(
          id_observation: '4000',
          numero: '12A57',
          texte: 'I can see you',
        )
      end

      it { is_expected.to be_success }
    end

    context 'when the observation does not exists' do
      it 'is created for the related dossier' do
        expect { subject }.to change(dossier.observations, :count).by(1)
      end

      it { is_expected.to be_success }
    end
  end

  context 'when associated dossier entreprise is not found' do
    it_behaves_like 'related dossier not found'
  end
end
