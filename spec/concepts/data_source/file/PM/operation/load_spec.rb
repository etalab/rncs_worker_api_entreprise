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
      # TODO test deserialization

      it 'calls the store operation' do
        expect(DataSource::File::PM::Operation::Store).to receive(:call)
        subject
      end

      context 'when storing operation fails' do
        before { allow(DataSource::File::PM::Operation::Store).to receive(:call).and_return(false) }

        it 'is failure' do
          expect(subject).to be_failure
        end

        it 'logs'
      end

      context 'when storing operation is successful' do
        before { allow(DataSource::File::PM::Operation::Store).to receive(:call).and_return(true) }

        it 'is success' do
          expect(subject).to be_success
        end

        it 'logs'
      end
    end
  end
end
