require 'rails_helper'

describe PersonnePhysique::Operation::Update do
  let(:data) do
    {
      code_greffe:    '1234',
      numero_gestion: '1A2B3C',
      nom_usage:      'Doe',
      pseudonyme:     'Johnny Johnny',
      eirl:           'Yep'
    }
  end

  subject { described_class.call(data: data) }

  context 'when the dossier is not found' do
    it_behaves_like 'related dossier not found'
  end

  context 'when the dossier is found' do
    context 'when the personne physique exists' do
      before do
        create(
          :dossier_entreprise_with_pp,
          code_greffe:    data[:code_greffe],
          numero_gestion: data[:numero_gestion]
        )
      end

      it { is_expected.to be_success }

      it 'updates the given fields' do
        subject
        dossier = DossierEntreprise.find_by(code_greffe: data[:code_greffe], numero_gestion: data[:numero_gestion])
        updated_pp = dossier.personne_physique

        expect(updated_pp).to have_attributes(
          code_greffe:    '1234',
          numero_gestion: '1A2B3C',
          nom_usage:      'Doe',
          pseudonyme:     'Johnny Johnny',
          eirl:           'Yep'
        )
      end
    end
  end

  context 'when the personne physique does not exist' do
    before do
      create(
        :dossier_entreprise,
        code_greffe:    data[:code_greffe],
        numero_gestion: data[:numero_gestion]
      )
    end

    it 'creates a new personne physique for the dossier' do
      subject
      dossier = DossierEntreprise.find_by(code_greffe: data[:code_greffe], numero_gestion: data[:numero_gestion])
      created_pp = dossier.personne_physique

      expect(created_pp).to have_attributes(
        code_greffe:    '1234',
        numero_gestion: '1A2B3C',
        nom_usage:      'Doe',
        pseudonyme:     'Johnny Johnny',
        eirl:           'Yep'
      )
    end

    it { is_expected.to be_success }
  end
end
