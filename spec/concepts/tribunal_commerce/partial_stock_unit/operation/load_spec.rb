require 'rails_helper'

describe TribunalCommerce::PartialStockUnit::Operation::Load, :trb do
  let(:logger) { instance_spy(Logger) }
  let(:unit) { create(:daily_update_unit, files_path: fixtures_path) }

  # This fixture archive contains the following files :
  # - 0384_S2_20180409_1_PM.csv
  # - 0384_S2_20180409_3_PP.csv
  # - 0384_S2_20180409_5_rep.csv
  # - 0384_S2_20180409_8_ets.csv
  # - 0384_S2_20180409_11_obs.csv
  # - 0384_S2_20180409_12_actes.csv
  # - 0384_S2_20180409_13_comptes_annuels.csv
  let(:fixtures_path) { Rails.root.join('spec/fixtures/tc/partial_stock/2018/04/09/0384_S2_20180409.zip') }

  subject { described_class.call(daily_update_unit: unit, logger: logger) }

  after do
    # Clean unit extraction directory
    FileUtils.rm_rf(Rails.root.join('tmp/0384_S2_20180409'))
  end

  it 'logs that the import starts' do
    subject

    expect(logger)
      .to have_received(:info)
      .with('Starting import of partial stock unit...')
  end

  describe 'unit archive extraction' do
    it 'calls ZIP::Operation::Extract' do
      expect_nested_operation_call(ZIP::Operation::Extract)

      subject
    end

    it 'fetches all the files inside unit archive' do
      unit_files = subject[:extracted_files]

      expect(unit_files).to contain_exactly(
        a_string_ending_with('tmp/0384_S2_20180409/0384_S2_20180409_1_PM.csv'),
        a_string_ending_with('tmp/0384_S2_20180409/0384_S2_20180409_3_PP.csv'),
        a_string_ending_with('tmp/0384_S2_20180409/0384_S2_20180409_5_rep.csv'),
        a_string_ending_with('tmp/0384_S2_20180409/0384_S2_20180409_8_ets.csv'),
        a_string_ending_with('tmp/0384_S2_20180409/0384_S2_20180409_11_obs.csv'),
        a_string_ending_with('tmp/0384_S2_20180409/0384_S2_20180409_12_actes.csv'),
        a_string_ending_with('tmp/0384_S2_20180409/0384_S2_20180409_13_comptes_annuels.csv'),
      )
    end

    context 'with an invalid archive' do
      let(:fixtures_path) { Rails.root.join('spec/fixtures/tc/falsey_stocks/unexpected_filename.zip') }

      it { is_expected.to be_failure }

      it 'logs the error' do
        subject

        expect(logger).to have_received(:error)
          .with("An error happened while trying to extract unit archive #{unit.files_path} : #{subject[:error]}")
      end
    end
  end

  describe 'filename deserialization' do
    it 'creates a hash of data from filenames' do
      data = subject[:files_args]

      expect(data).to contain_exactly(
        a_hash_including(code_greffe: '0384', label: 'PM', path: a_string_ending_with('0384_S2_20180409_1_PM.csv')),
        a_hash_including(code_greffe: '0384', label: 'PP', path: a_string_ending_with('0384_S2_20180409_3_PP.csv')),
        a_hash_including(code_greffe: '0384', label: 'rep', path: a_string_ending_with('0384_S2_20180409_5_rep.csv')),
        a_hash_including(code_greffe: '0384', label: 'ets', path: a_string_ending_with('0384_S2_20180409_8_ets.csv')),
        a_hash_including(code_greffe: '0384', label: 'obs', path: a_string_ending_with('0384_S2_20180409_11_obs.csv')),
        a_hash_including(code_greffe: '0384', label: 'actes', path: a_string_ending_with('0384_S2_20180409_12_actes.csv')),
        a_hash_including(code_greffe: '0384', label: 'comptes_annuels', path: a_string_ending_with('0384_S2_20180409_13_comptes_annuels.csv')),
      )
    end

    context 'when filenames are invalid' do
      before do
        allow_any_instance_of(TribunalCommerce::Helper::DataFile)
          .to receive(:parse_stock_filename)
          .and_raise(TribunalCommerce::Helper::DataFile::UnexpectedFilename, 'much error')
      end

      it { is_expected.to be_failure }

      it 'logs the error' do
        subject

        expect(logger).to have_received(:error)
          .with('An error occured while parsing unit\'s files : much error')
      end
    end
  end

  describe 'unit\'s files import' do
    it 'depends on TribunalCommerce::Helper::FileImporter for import' do
      file_importer = subject[:file_importer]

      expect(file_importer).to eq(TribunalCommerce::Helper::FileImporter)
    end

    it 'imports data files in the right order' do
      importer = class_spy(TribunalCommerce::Helper::FileImporter)
      described_class.call(daily_update_unit: unit, logger: logger, file_importer: importer)

      expect(importer).to have_received(:supersede_dossiers_entreprise_from_pm)
        .with(a_string_ending_with('0384_S2_20180409_1_PM.csv'))
        .ordered
      expect(importer).to have_received(:import_personnes_morales)
        .with(a_string_ending_with('0384_S2_20180409_1_PM.csv'))
        .ordered
      expect(importer).to have_received(:supersede_dossiers_entreprise_from_pp)
        .with(a_string_ending_with('0384_S2_20180409_3_PP.csv'))
        .ordered
      expect(importer).to have_received(:import_personnes_physiques)
        .with(a_string_ending_with('0384_S2_20180409_3_PP.csv'))
        .ordered
      expect(importer).to have_received(:import_representants)
        .with(a_string_ending_with('0384_S2_20180409_5_rep.csv'))
        .ordered
      expect(importer).to have_received(:import_etablissements)
        .with(a_string_ending_with('0384_S2_20180409_8_ets.csv'))
        .ordered
      expect(importer).to have_received(:import_observations)
        .with(a_string_ending_with('0384_S2_20180409_11_obs.csv'))
        .ordered
    end

    context 'when a file\'s import fails' do
      # Stub a fail import on dossier entreprise from a PP file
      let(:importer) do
        dbl = class_spy(TribunalCommerce::Helper::FileImporter)
        allow(dbl).to receive(:supersede_dossiers_entreprise_from_pm).and_return(true)
        allow(dbl).to receive(:import_personnes_morales).and_return(true)
        allow(dbl).to receive(:supersede_dossiers_entreprise_from_pp).and_return(false)
        dbl
      end

      subject { described_class.call(daily_update_unit: unit, logger: logger, file_importer: importer) }

      it { is_expected.to be_failure }

      it 'does not import the following files' do
        subject

        expect(importer).to_not have_received(:import_personnes_physiques)
        expect(importer).to_not have_received(:import_representants)
        expect(importer).to_not have_received(:import_etablissements)
        expect(importer).to_not have_received(:import_observations)
      end
    end
  end
end
