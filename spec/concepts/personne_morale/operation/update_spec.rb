require 'rails_helper'

describe PersonneMorale::Operation::Update do
  let(:data) do
    {
      code_greffe: '1234',
      numero_gestion: '1A2B3C',
      denomination: 'Evil Corp',
      devise: 'EUR',
      forme_juridique: 'SAS',
      capital: '1000',
    }
  end

  subject { described_class.call(data: data) }

  context 'when the dossier is not found' do
    it_behaves_like 'related dossier not found'
  end

  context 'when the dossier is found' do
    before do
      create(
        :dossier_entreprise_with_pm,
        code_greffe: data[:code_greffe],
        numero_gestion: data[:numero_gestion],
      )
    end

    it { is_expected.to be_success }

    it 'updates the given fields' do
      subject
      dossier = DossierEntreprise.find_by(code_greffe: data[:code_greffe], numero_gestion: data[:numero_gestion])
      updated_pm = dossier.personne_morale

      expect(updated_pm).to have_attributes(
        code_greffe: '1234',
        numero_gestion: '1A2B3C',
        denomination: 'Evil Corp',
        devise: 'EUR',
        forme_juridique: 'SAS',
        capital: '1000'
      )
    end
  end
end
