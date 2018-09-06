require 'rails_helper'

describe DataSource::File::Operation::Import do
  describe 'import by batch' do
    # batch size is set in the configuration file
    let(:batch_size) { Rails.configuration.rncs_sources.fetch('import_batch_size') }

    let(:op_params) do
      { file_path: path_for(:pm_stock_file) }
    end

    let(:logger) do
      d = double()
      allow(d).to receive(:info)
      d
    end

    subject { described_class.call({}, params: op_params, logger: logger) }

    it 'calls DataSource::File::Operation::BatchImport multiple times' do
      expect(DataSource::File::Operation::BatchImport)
        .to receive(:call).exactly(8).times # csv contains 38 rows + header

      subject
    end

    it 'logs when loading each batch' do
      expect(logger).to receive(:info).with('Processing batch number 1')
      expect(logger).to receive(:info).with('Processing batch number 2')
      expect(logger).to receive(:info).with('Processing batch number 3')
      expect(logger).to receive(:info).with('Processing batch number 4')
      expect(logger).to receive(:info).with('Processing batch number 5')
      expect(logger).to receive(:info).with('Processing batch number 6')
      expect(logger).to receive(:info).with('Processing batch number 7')
      expect(logger).to receive(:info).with('Processing batch number 8')

      subject
    end
  end
end
