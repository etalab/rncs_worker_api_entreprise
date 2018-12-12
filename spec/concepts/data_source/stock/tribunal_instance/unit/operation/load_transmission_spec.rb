require 'rails_helper'

describe DataSource::Stock::TribunalInstance::Unit::Operation::LoadTransmission do
  subject do
    described_class.call(
      code_greffe: '9712',
      path: spec_path.to_s,
      logger: logger
    )
  end

  let(:spec_path) { Rails.root.join 'spec', 'fixtures', 'titmc', 'zip', filename }
  let(:logger) { object_double(Rails.logger, info: true).as_null_object }

  context 'when zip exists' do
    context 'when import is successful' do
      let(:filename) { '9712_S1_20180505_lot02_modified.zip' }

      it { is_expected.to be_success }

      it 'persists some data'

      it 'deletes extract directory' do
        directory = Pathname(subject[:dest_directory])
        expect(directory).not_to exist
      end
    end

    context 'when Prechecks fails' do
      let(:filename) { 'two_files.zip' }

      it { is_expected.to be_failure }
    end

    context 'when Import fails' do
      it 'is a failure'
    end
  end

  context 'when ZIP contains too many files' do
    let(:filename) { 'two_files.zip' }

    it { is_expected.to be_failure }

    it 'logs an error' do
      expect(logger)
        .to receive(:error)
        .with 'Zip file two_files.zip contains too many files (expected 1 got 2)'
      subject
    end
  end

  context 'when ZIP::Operation::Extract fails' do
    let(:filename) { 'missing_file.zip' }

    it { is_expected.to be_failure }

    it 'does not persists anything'

    it 'deletes extract directory' do
      directory = Pathname(subject[:dest_directory])
      expect(directory).not_to exist
    end

    it 'logs an error' do
      expect(logger)
        .to receive(:error)
        .with /unzip:  cannot find or open .+/
      subject
    end
  end
end
