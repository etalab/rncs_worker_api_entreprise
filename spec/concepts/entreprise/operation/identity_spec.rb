require 'rails_helper'

describe Entreprise::Operation::Identity do
  subject { described_class.call(siren: siren) }

  let(:http_error) { subject[:http_error] }

  context 'when daily updates have been successfully imported' do
    before do
      create(:daily_update_with_completed_units, year: '2012', month: '03', day: '13')
      create(:daily_update_with_completed_units, year: '2015', month: '09', day: '27')
    end

    context 'with an invalid siren' do
      let(:siren) { invalid_siren }

      it { is_expected.to be_failure }

      it 'returns a 422 error' do
        expect(http_error[:code]).to eq(422)
        expect(http_error[:message]).to eq('Le numéro siren en paramètre est mal formaté.')
      end
    end

    context 'when no immatriculation principale is found' do
      let(:siren) { valid_siren }

      before do
        allow(DossierEntreprise).to receive(:immatriculation_principale)
          .with(siren)
          .and_return(nil)
      end

      it { is_expected.to be_failure }

      it 'returns a 404 HTTP code' do
        expect(http_error[:code]).to eq(404)
      end

      it 'returns an error message' do
        expect(http_error[:message]).to match("Immatriculation principale non trouvée pour le siren #{siren}.")
      end
    end

    context 'when the immatriculation principale is found' do
      let(:siren) { valid_siren }
      let!(:dossier) { create(:dossier_entreprise, code_greffe: 'code_test', numero_gestion: 'numero_test', type_inscription: 'P', siren: siren) }

      before do
        allow(DossierEntreprise).to receive(:immatriculation_principale)
          .with(siren)
          .and_return(dossier)
      end

      context 'when an etablissement principal is found in this dossier' do
        before { create(:etablissement_principal, dossier_entreprise: dossier, enseigne: 'do not forget me') }

        let(:entreprise_identity) { subject[:entreprise_identity] }

        it { is_expected.to be_success }

        describe 'entreprise identity data' do
          it 'returns dossier principal attributes' do
            dossier_attributes = entreprise_identity.fetch(:dossier_entreprise_greffe_principal)

            expect(dossier_attributes).to include(
              code_greffe: 'code_test',
              numero_gestion: 'numero_test',
              siren: valid_siren,
              type_inscription: 'P'
              # Ensure other keys are returned as well ? Here or inside the controller's spec ?
            )
          end

          it 'returns all observations associated to the dossier principal' do
            create(:observation, dossier_entreprise: dossier, texte: 'control value 1')
            create(:observation, dossier_entreprise: dossier, texte: 'control value 2')
            create(:observation, texte: 'ghost')

            observations_list = entreprise_identity.fetch(:dossier_entreprise_greffe_principal).fetch(:observations)

            expect(observations_list).to contain_exactly(
              a_hash_including(texte: 'control value 1'),
              a_hash_including(texte: 'control value 2')
            )
          end

          it 'returns all representants associated to the dossier principal' do
            create(:representant, dossier_entreprise: dossier, qualite: 'control value 1')
            create(:representant, dossier_entreprise: dossier, qualite: 'control value 2')
            create(:representant, qualite: 'ghost')

            representants_list = entreprise_identity.fetch(:dossier_entreprise_greffe_principal).fetch(:representants)

            expect(representants_list).to contain_exactly(
              a_hash_including(qualite: 'control value 1'),
              a_hash_including(qualite: 'control value 2')
            )
          end

          it 'returns all etablissements associated to the dossier principal' do
            create(:etablissement, dossier_entreprise: dossier, activite: 'control value 1')
            create(:etablissement, dossier_entreprise: dossier, activite: 'control value 2')
            create(:etablissement, activite: 'ghost')

            etablissements_list = entreprise_identity.fetch(:dossier_entreprise_greffe_principal).fetch(:etablissements)

            expect(etablissements_list).to contain_exactly(
              a_hash_including(activite: 'control value 1'),
              a_hash_including(activite: 'control value 2'),
              a_hash_including(enseigne: 'do not forget me') # created in before hook for happy path
            )
          end

          it 'returns associated personne morale attributes' do
            create(:personne_morale, dossier_entreprise: dossier, capital: '42')
            pm_fields = entreprise_identity.fetch(:dossier_entreprise_greffe_principal).fetch(:personne_morale)

            expect(pm_fields).to include(capital: '42')
          end

          it 'returns associated personne physique attributes' do
            create(:personne_physique, dossier_entreprise: dossier, pseudonyme: 'xXxBrinduxXx')
            pp_fields = entreprise_identity.fetch(:dossier_entreprise_greffe_principal).fetch(:personne_physique)

            expect(pp_fields).to include(pseudonyme: 'xXxBrinduxXx')
          end

          it 'returns etablissement principal' do
            etablissement_principal = entreprise_identity.fetch(:dossier_entreprise_greffe_principal).fetch(:etablissement_principal)
            expect(etablissement_principal).to include(enseigne: 'do not forget me')
          end
        end

        describe '#db_current_date' do
          shared_examples 'returning the last completed update date' do
            it do
              dossier_attr = entreprise_identity.fetch(:dossier_entreprise_greffe_principal)

              expect(dossier_attr).to include(db_current_date: '2015-09-27')
            end
          end

          context 'when all daily updates have been successfully imported' do
            it_behaves_like 'returning the last completed update date'
          end

          context 'with a currently running update' do
            before { create(:daily_update_with_one_loading_unit, year: '2015', month: '09', day: '28') }

            it_behaves_like 'returning the last completed update date'
          end

          context 'with the last update in error' do
            before { create(:daily_update_with_one_error_unit, year: '2015', month: '09', day: '28') }

            it_behaves_like 'returning the last completed update date'
          end
        end
      end

      context 'when no etablissement principal is found' do
        it { is_expected.to be_failure }

        it 'returns a 404 error' do
          expect(http_error[:code]).to eq(404)
          expect(http_error[:message]).to eq('Aucun établissement principal dans le dossier d\'immatriculation.')
        end
      end
    end
  end

  context 'when no stocks or updates have been successfully imported yet' do
    let(:siren) { valid_siren }

    it { is_expected.to be_failure }

    it 'returns a HTTP error' do
      expect(http_error).to match(
        code: 501,
        message: 'Nothing load into the database yet: please import the last stock available.'
      )
    end
  end
end
