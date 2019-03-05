require 'rails_helper'

describe TribunalCommerce::DailyUpdateUnit::Operation::ImportTransmission, :trb do
  let(:logger) { instance_spy(Logger).as_null_object }

  # Unit tests here so we mock the file importer dependency
  let(:file_importer) do
    dbl = instance_spy(TribunalCommerce::Helper::FileImporter)
    dbl
  end

  subject { described_class.call(files_path: example_path, logger: logger, file_importer: file_importer) }

  context 'when folder contains files' do
    context 'when filenames pattern are valid' do
      let(:example_path) { Rails.root.join('spec/fixtures/example/tc/transmission/valid_files') }

      it { is_expected.to be_success }

      it 'deserializes the file names' do
        data = subject[:files_args]

        expect(data).to contain_exactly(
          a_hash_including(
            code_greffe: '0101',
            label: 'PM',
            path: a_string_ending_with('0101_1_20170512_112544_1_PM.csv')
          ),
          a_hash_including(
            code_greffe: '0101',
            label: 'PM_EVT',
            path: a_string_ending_with('0101_1_20170512_112544_2_PM_EVT.csv')
          ),
          a_hash_including(
            code_greffe: '0101',
            label: 'PP',
            path: a_string_ending_with('0101_1_20170512_112544_3_PP.csv')
          ),
          a_hash_including(
            code_greffe: '0101',
            label: 'PP_EVT',
            path: a_string_ending_with('0101_1_20170512_112544_4_PP_EVT.csv')
          ),
          a_hash_including(
            code_greffe: '0101',
            label: 'rep',
            path: a_string_ending_with('0101_1_20170512_112544_5_rep.csv')
          ),
          a_hash_including(
            code_greffe: '0101',
            label: 'rep_nouveau_modifie_EVT',
            path: a_string_ending_with('0101_1_20170512_112544_6_rep_nouveau_modifie_EVT.csv')
          ),
          a_hash_including(
            code_greffe: '0101',
            label: 'rep_partant_EVT',
            path: a_string_ending_with('0101_1_20170512_112544_7_rep_partant_EVT.csv')
          ),
          a_hash_including(
            code_greffe: '0101',
            label: 'ets',
            path: a_string_ending_with('0101_1_20170512_112544_8_ets.csv')
          ),
          a_hash_including(
            code_greffe: '0101',
            label: 'ets_nouveau_modifie_EVT',
            path: a_string_ending_with('0101_1_20170512_112544_9_ets_nouveau_modifie_EVT.csv')
          ),
          a_hash_including(
            code_greffe: '0101',
            label: 'ets_supprime_EVT',
            path: a_string_ending_with('0101_1_20170512_112544_10_ets_supprime_EVT.csv')
          ),
          a_hash_including(
            code_greffe: '0101',
            label: 'obs',
            path: a_string_ending_with('0101_1_20170512_112544_11_obs.csv')
          ),
          a_hash_including(
            code_greffe: '0101',
            label: 'actes',
            path: a_string_ending_with('0101_1_20170512_112544_12_actes.csv')
          ),
          a_hash_including(
            code_greffe: '0101',
            label: 'comptes_annuels',
            path: a_string_ending_with('0101_1_20170512_112544_13_comptes_annuels.csv')
          ),
        )
      end

      it 'imports each files in the right order' do
        subject

        expect_ordered_import_call(:import_dossiers_entreprise_from_pm, '0101_1_20170512_112544_1_PM.csv')
        expect_ordered_import_call(:import_personnes_morales, '0101_1_20170512_112544_1_PM.csv')
        expect_ordered_import_call(:import_dossiers_entreprise_evt_from_pm, '0101_1_20170512_112544_2_PM_EVT.csv')
        expect_ordered_import_call(:import_personnes_morales_evt, '0101_1_20170512_112544_2_PM_EVT.csv')
        expect_ordered_import_call(:import_dossiers_entreprise_from_pp, '0101_1_20170512_112544_3_PP.csv')
        expect_ordered_import_call(:import_personnes_physiques, '0101_1_20170512_112544_3_PP.csv')
        expect_ordered_import_call(:import_dossiers_entreprise_evt_from_pp, '0101_1_20170512_112544_4_PP_EVT.csv')
        expect_ordered_import_call(:import_personnes_physiques_evt, '0101_1_20170512_112544_4_PP_EVT.csv')
        expect_ordered_import_call(:import_representants, '0101_1_20170512_112544_5_rep.csv')
        expect_ordered_import_call(:import_representants_nouveau_modifie, '0101_1_20170512_112544_6_rep_nouveau_modifie_EVT.csv')
        expect_ordered_import_call(:import_representants_partant, '0101_1_20170512_112544_7_rep_partant_EVT.csv')
        expect_ordered_import_call(:import_etablissements, '0101_1_20170512_112544_8_ets.csv')
        expect_ordered_import_call(:import_etablissements_nouveau_modifie, '0101_1_20170512_112544_9_ets_nouveau_modifie_EVT.csv')
        expect_ordered_import_call(:import_etablissements_supprime, '0101_1_20170512_112544_10_ets_supprime_EVT.csv')
        expect_ordered_import_call(:import_observations, '0101_1_20170512_112544_11_obs.csv')

      end

      it 'logs overall transmission\'s import success' do
        subject

        expect(logger).to have_received(:info).with('All files have been successfuly imported !')
      end

      context 'when one file fails to import' do
        before { allow(file_importer).to receive(:import_representants_partant).and_return(false) }

        it { is_expected.to be_failure }

        it 'logs the failure of transmission import' do
          subject

          expect(logger).to have_received(:error)
            .with("An error occured while importing a file, abort import of transmission...")
        end

        # Actually useless since the import runs in a transaction
        # Might be deleted to improve spec's suite runtime
        it 'does not import following files' do
          subject

          expect(file_importer).to_not have_received(:import_etablissements)
          expect(file_importer).to_not have_received(:import_etablissements_nouveau_modifie)
          expect(file_importer).to_not have_received(:import_etablissements_supprime)
          expect(file_importer).to_not have_received(:import_observations)
        end
      end
    end

    context 'when filenames pattern is unexpected' do
      it 'is failure'
      it 'logs'
    end
  end

  context 'when folder is empty' do
    # fixture folder contains a single .md5 file and no .csv
    let(:example_path) { Rails.root.join('spec/fixtures/example/tc/transmission/no_data_files') }

    it { is_expected.to be_failure }

    it 'logs'
  end

  def expect_ordered_import_call(import_name, file_path)
    expect(file_importer).to have_received(import_name)
      .with(a_string_ending_with(file_path))
      .ordered
  end
end
