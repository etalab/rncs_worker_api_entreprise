require 'rails_helper'

describe DataSource::File::PM::Operation::Load do
  let(:file_path) { path_for(:pm_stock_file)}
  subject { described_class.call(file_path: file_path) }
  let(:errors) { subject[:errors] }

  describe ':file_path argument' do
    context 'when it is not given' do
      let(:file_path) { nil }

      it 'fails' do
        expect(subject).to be_failure
        expect(errors).to eq('No file path given')
      end
    end

    context 'when file does not exist' do
      let(:file_path) { 'not_a_file_path' }

      it 'fails' do
        expect(subject).to be_failure
        expect(errors).to eq('File \'not_a_file_path\' does not exist.')
      end
    end

    context 'when the file is valid' do
      let(:stub_success) do
        result = double()
        allow(result).to receive(:failure?).and_return(false)
        result
      end

      let(:stub_failure) do
        result = double()
        allow(result).to receive(:failure?).and_return(true)
        result
      end

      it 'delegates the pm creation' do
        expect(Entreprise::Operation::CreateWithPM)
          .to receive(:call).exactly(5).times.and_return(stub_success) # 5 lines in the csv example file
        subject
      end

      context 'when a few import fails' do
        before do
          # let's say that 2 rows import have failed
          expect(Entreprise::Operation::CreateWithPM)
            .to receive(:call).twice.and_return(stub_failure)
          expect(Entreprise::Operation::CreateWithPM)
            .to receive(:call).exactly(3).times.and_return(stub_success)
        end

        it 'is successfull' do
          expect(subject).to be_success
        end

        it 'keeps count of errors' do
          import_errors = subject[:import_errors]
          expect(import_errors).to eq(2)
        end

        it 'logs the import result' # log "123 of 146 PM have been imported ..."
      end

      context 'when all file import fails' do
        before do
          expect(Entreprise::Operation::CreateWithPM)
            .to receive(:call).exactly(5).times.and_return(stub_failure)
        end

        it 'is failure' do
          expect(subject).to be_failure
        end

        it 'logs' # log "No data import from _filename_"
      end
    end
  end
end
