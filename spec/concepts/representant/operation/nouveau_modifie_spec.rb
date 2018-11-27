require 'rails_helper'

describe Representant::Operation::NouveauModifie do
  let(:data) do
    {
      code_greffe: '1234',
      numero_gestion: '1A2B3C',
      id_representant: '1',
      qualite: 'Président',
      denomination: 'Holding my beer',
      siren_pm: '123456789',
      representant_permanent_adresse_ligne_1: '23 rue bidon',
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

    context 'when the representant exists' do
      before do
        create(:representant, id_representant: '1', qualite: 'Président', dossier_entreprise: dossier)
      end

      it { is_expected.to be_success }

      it 'updates the representant' do
        subject
        updated_rep = dossier.representants.find_by(id_representant: '1', qualite: 'Président')

        expect(updated_rep).to have_attributes(
          denomination: 'Holding my beer',
          siren_pm: '123456789',
          representant_permanent_adresse_ligne_1: '23 rue bidon'
        )
      end
    end

    context 'when the representant does not exist' do
      before { dossier }

      it { is_expected.to be_success }

      it 'creates a new representant associated with the dossier' do
        expect { subject }.to change(dossier.representants, :count).by(1)
      end

      it 'returns a warning message' do
        warning_msg = subject[:warning]

        expect(warning_msg).to eq('The representant (id_representant: 1, qualite: Président) was not found in dossier (code_greffe: 1234, numero_gestion: 1A2B3C). Representant created instead.')
      end
    end
  end

  # TODO https://github.com/etalab/rncs_worker_api_entreprise/issues/39
  context 'when the related dossier is not found' do
    it 'returns a warning message' do
      warning_msg = subject[:warning]

      expect(warning_msg).to eq("The dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}) is not found. The representant (id_representant: #{data[:id_representant]}, qualite: #{data[:qualite]}) is not imported.")
    end

    it { is_expected.to be_success }
  end
end
