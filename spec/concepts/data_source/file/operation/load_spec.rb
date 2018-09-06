require 'rails_helper'

describe DataSource::File::Operation::Load do
  let(:op_params) do
    {
      file_path: 'spec/data_source_example/real_file.csv'
    }
  end
  subject { described_class.call(params: op_params) }

  describe 'expected arguments' do
    describe ':file_path' do
      let(:errors) { subject['result.contract.default'].errors[:file_path] }

      context 'when not filled' do
        let(:op_params) { { file_path: nil } }

        it { is_expected.to be_failure }

        it 'sets an error' do
          expect(errors).to include 'must be filled'
        end
      end

      context 'when file is invalid' do
        let(:op_params) { { file_path: '/ima/ghost/file.csv' } }

        it { is_expected.to be_failure }

        it 'sets an error' do
          expect(errors)
            .to include "File #{op_params[:file_path]} does not exist or is no regular file"
        end
      end
    end
  end

  context 'when given file is valid' do
    let(:created_log_file) { Rails.root.join('log', 'tc_stock', 'real_file.log').to_s }

    # Still looking for a way to stub different tasks
    # Import tasks should not be called in unit specs
    after { FileUtils.rm_rf(created_log_file) }
    before { allow(DataSource::File::Operation::Import).to receive(:call).and_return(true) }

    describe 'logger setup' do
      its([:logger]) { is_expected.to be_an_instance_of Logger }

      it 'creates a log file named after the file to import' do
        subject
        expect(File.file?(created_log_file)).to eq(true)
      end

      it 'logs the begining of the file import' do
        expect_any_instance_of(Logger).to receive(:info).with('Start file import...')
        subject
      end

      # TODO Stub or extract the logger the right way to be able to test log actions like this
      # its([:logger]) { is_expected.to receive(:info).with('Start import...') }
    end

    describe 'import' do
      it 'delegates to DataSource::File::Operation::Import' do
        expect(DataSource::File::Operation::Import).to receive(:call)
        # TODO look at trailblaizer internals for the .call method signature
        # and then test the call arguments

        subject
      end
    end
  end
end
