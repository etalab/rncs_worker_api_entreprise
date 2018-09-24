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

  describe 'import' do
    let(:random_worker) do
      Class.new do
        def self.call(*args); end
      end
    end
    let(:op_params) do
      {
        file_path: 'spec/data_source_example/real_file.csv',
        import_worker: random_worker
      }
    end

    subject { described_class.call(params: op_params) }

    # TODO expect the right arguments
    it 'delegates the import to the given operation in params' do
      expect(random_worker).to receive(:call)
      subject
    end
  end
end
