require 'rails_helper'

describe Entreprise::Operation::Identity do
  subject { described_class.call(siren: siren) }
  let(:http_error) { subject[:http_error] }

  context 'with an invalid siren' do
    let(:siren) { invalid_siren }

    it { is_expected.to be_failure }

    it 'returns a 422 error' do
      expect(http_error[:code]).to eq(422)
      expect(http_error[:message]).to eq('Siren invalide')
    end
  end

  context 'when no dossiers are found' do
    let(:siren) { valid_siren }

    it { is_expected.to be_failure }

    it 'sets a 404 http error' do
      expect(http_error[:code]).to eq(404)
      expect(http_error[:message]).to eq('Aucun dossier trouvé.')
    end
  end

  context 'with no exclusif dossier principal' do
    let(:siren) { valid_siren }

    shared_examples 'no exclusif dossier principal' do
      it { is_expected.to be_failure }

      it 'returns a 500 error' do
        expect(http_error[:code]).to eq(500)
        expect(http_error[:message]).to match(/\A\d+ dossiers principaux trouvés\Z/)
      end
    end

    context 'with 0 dossier principal' do
      before { create(:dossier_entreprise, type_inscription: 'S', siren: siren) }

      it_behaves_like 'no exclusif dossier principal'
    end

    context 'with 2 dossier principal' do
      before { create_list(:dossier_entreprise, 3, type_inscription: 'S', siren: siren) }
      it_behaves_like 'no exclusif dossier principal'
    end
  end

  context 'with one and only one dossier principal' do
    let(:siren) { valid_siren }
    let(:dossier) { create(:dossier_entreprise, code_greffe: 'code_test', numero_gestion: 'numero_test', type_inscription: 'P', siren: siren) }

    before { dossier }

    context 'when an etablissement principal is found in this dossier' do
      before { create(:etablissement_principal, dossier_entreprise: dossier, enseigne: 'do not forget me') }

      it { is_expected.to be_success }

      describe 'entreprise identity data' do
        let(:entreprise_identity) { subject[:entreprise_identity] }

        it 'returns dossier principal attributes' do
          dossier_attributes = entreprise_identity.fetch(:dossier_entreprise_greffe_principal)

          expect(dossier_attributes).to include(
            'code_greffe' => 'code_test',
            'numero_gestion' => 'numero_test',
            'siren' => valid_siren,
            'type_inscription' => 'P',
            # Ensure other keys are returned as well ? Here or inside the controller's spec ?
          )
        end

        it 'returns all observations associated to the dossier principal' do
          create(:observation, dossier_entreprise: dossier, texte: 'control value 1')
          create(:observation, dossier_entreprise: dossier, texte: 'control value 2')
          create(:observation, texte: 'ghost')

          observations_list = entreprise_identity.fetch(:dossier_entreprise_greffe_principal).fetch(:observations)

          expect(observations_list).to contain_exactly(
            a_hash_including('texte' => 'control value 1'),
            a_hash_including('texte' => 'control value 2'),
          )
        end

        it 'returns all representants associated to the dossier principal' do
          create(:representant, dossier_entreprise: dossier, qualite: 'control value 1')
          create(:representant, dossier_entreprise: dossier, qualite: 'control value 2')
          create(:representant, qualite: 'ghost')

          representants_list = entreprise_identity.fetch(:dossier_entreprise_greffe_principal).fetch(:representants)

          expect(representants_list).to contain_exactly(
            a_hash_including('qualite' => 'control value 1'),
            a_hash_including('qualite' => 'control value 2'),
          )
        end

        it 'returns all etablissements associated to the dossier principal' do
          create(:etablissement, dossier_entreprise: dossier, activite: 'control value 1')
          create(:etablissement, dossier_entreprise: dossier, activite: 'control value 2')
          create(:etablissement, activite: 'ghost')

          etablissements_list = entreprise_identity.fetch(:dossier_entreprise_greffe_principal).fetch(:etablissements)

          expect(etablissements_list).to contain_exactly(
            a_hash_including('activite' => 'control value 1'),
            a_hash_including('activite' => 'control value 2'),
            a_hash_including('enseigne' => 'do not forget me'), # created in before hook for happy path
          )
        end

        it 'returns associated personne morale attributes' do
          create(:personne_morale, dossier_entreprise: dossier, capital: '42')
          pm_fields = entreprise_identity.fetch(:dossier_entreprise_greffe_principal).fetch(:personne_morale)

          expect(pm_fields).to include('capital' => '42')
        end

        it 'returns associated personne physique attributes' do
          create(:personne_physique, dossier_entreprise: dossier, pseudonyme: 'xXxBrinduxXx')
          pp_fields = entreprise_identity.fetch(:dossier_entreprise_greffe_principal).fetch(:personne_physique)

          expect(pp_fields).to include('pseudonyme' => 'xXxBrinduxXx')
        end
      end
    end

    context 'when no etablissement principal is found' do
      it { is_expected.to be_failure }

      it 'returns a 500 error' do
        expect(http_error[:code]).to eq(500)
        expect(http_error[:message]).to eq('Aucun etablissement principal trouvé dans le dossier principal')
      end
    end
  end
end

