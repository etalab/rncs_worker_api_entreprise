require 'rails_helper'

describe TribunalCommerce::DailyUpdateUnit::Operation::ImportTransmission, :trb do
  let(:logger) { instance_double(Logger).as_null_object }
  subject { described_class.call(files_path: example_path, logger: logger) }

  context 'when folder contains files' do
    context 'when filenames pattern are valid' do
      context 'when files type are well-known' do
        let(:example_path) { Rails.root.join('spec/fixtures/example/tc/transmission/valid_files') }

        before { allow_success_for_every_file_import }

        it { is_expected.to be_success }

        it 'maps each file to its own worker' do
          data = subject[:files_args]

          expect(data).to include(
            a_hash_including(label: 'PM', import_worker: expected_mapping['PM']),
            a_hash_including(label: 'PM_EVT', import_worker: expected_mapping['PM_EVT']),
            a_hash_including(label: 'PP', import_worker: expected_mapping['PP']),
            a_hash_including(label: 'PP_EVT', import_worker: expected_mapping['PP_EVT']),
            a_hash_including(label: 'rep', import_worker: expected_mapping['rep']),
            a_hash_including(label: 'rep_nouveau_modifie_EVT', import_worker: expected_mapping['rep_nouveau_modifie_EVT']),
            a_hash_including(label: 'rep_partant_EVT', import_worker: expected_mapping['rep_partant_EVT']),
            a_hash_including(label: 'ets', import_worker: expected_mapping['ets']),
            a_hash_including(label: 'ets_nouveau_modifie_EVT', import_worker: expected_mapping['ets_nouveau_modifie_EVT']),
            a_hash_including(label: 'ets_supprime_EVT', import_worker: expected_mapping['ets_supprime_EVT']),
            a_hash_including(label: 'obs', import_worker: expected_mapping['obs']),
          )
        end

        it 'calls the given worker for each file' do
          mocked_worker = double('worker', call: trb_result_success)
          allow_any_instance_of(TribunalCommerce::Helper::DataFile)
            .to receive(:map_import_worker)
            .and_return([{ import_worker: mocked_worker, path: 'file path' }])
          expect(mocked_worker).to receive(:call).with(file_path: 'file path')

          subject
        end

        it 'logs file import start' do
          expected_mapping.keys.each do |label|
            expect(logger).to receive(:info)
              .with(a_string_starting_with('Starting import of file')
                .and(a_string_ending_with("#{label}.csv..."))
              )
          end

          subject
        end

        it 'imports files in the right order' do
          expect_ordered_import_for_file('PM')
          expect_ordered_import_for_file('PM_EVT')
          expect_ordered_import_for_file('PP')
          expect_ordered_import_for_file('PP_EVT')
          expect_ordered_import_for_file('rep')
          expect_ordered_import_for_file('rep_nouveau_modifie_EVT')
          expect_ordered_import_for_file('rep_partant_EVT')
          expect_ordered_import_for_file('ets')
          expect_ordered_import_for_file('ets_nouveau_modifie_EVT')
          expect_ordered_import_for_file('ets_supprime_EVT')
          expect_ordered_import_for_file('obs')

          subject
        end

        it 'logs file import success' do
          expected_mapping.keys.each do |label|
            expect(logger).to receive(:info)
              .with(a_string_starting_with('Import of file').and a_string_ending_with("#{label}.csv is complete"))
          end

          subject
        end

        it 'logs overall transmission\'s import success' do
          expect(logger).to receive(:info).with('All files have been successfuly imported !')

          subject
        end

        context 'when one file fails to import' do
          before { allow_one_file_import_to_fail }

          it { is_expected.to be_failure }

          it 'logs the file import failure' do
            expect(logger).to receive(:error)
              .with(a_string_starting_with('Import of file').and a_string_ending_with('PM.csv failed. Aborting import...'))

            subject
          end

          it 'does not import following files' do
            # Expect file import not to be called for every files except 'PM'
            # (the one failing to import)
            map = expected_mapping
            map.delete('PM')
            map.each do |label, worker|
              expect(worker).to_not receive(:call)
            end

            subject
          end
        end
      end

      context 'when files type are unknown' do
        it 'is failure'
        it 'logs'
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

    it 'logs' do

    end
  end

  def expect_ordered_import_for_file(label)
    expect(expected_mapping[label]).to receive(:call).and_return(trb_result_success).ordered
  end

  def expected_mapping
    {
      'PM' =>     DataSource::File::PM::Operation::Import,
      'PM_EVT' => TribunalCommerce::File::PMEvent::Operation::Import,
      'PP' =>     DataSource::File::PP::Operation::Import,
      'PP_EVT' => TribunalCommerce::File::PPEvent::Operation::Import,
      'rep' =>    DataSource::File::Rep::Operation::Import,
      'rep_nouveau_modifie_EVT' => TribunalCommerce::File::RepNouveauModifie::Operation::Import,
      'rep_partant_EVT' => TribunalCommerce::File::RepPartant::Operation::Import,
      'ets' =>    DataSource::File::Ets::Operation::Import,
      'ets_nouveau_modifie_EVT' => TribunalCommerce::File::EtsNouveauModifie::Operation::Import,
      'ets_supprime_EVT' => TribunalCommerce::File::EtsSupprime::Operation::Import,
      'obs' =>    DataSource::File::Obs::Operation::Import,
    }
  end

  def allow_success_for_every_file_import
    expected_mapping.each do |label, worker|
      allow(worker).to receive(:call).and_return(trb_result_success)
    end
  end

  def allow_one_file_import_to_fail
    allow(expected_mapping['PM']).to receive(:call).and_return(trb_result_failure)
  end
end
