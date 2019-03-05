require 'rails_helper'

describe TribunalInstance::Stock::Unit::Operation::LoadTransmission, :trb do
  subject do
    described_class.call(
      code_greffe: '9712',
      path: spec_path.to_s,
      logger: logger
    )
  end

  let(:spec_path) { Rails.root.join 'spec', 'fixtures', 'titmc', 'zip', filename }
  let(:logger) { instance_double(Logger).as_null_object }

  context 'when zip exists' do
    let(:filename) { '9712_S1_20180505_lot02.zip' }

    it 'logs import start' do
      expect(logger).to receive(:info).with(/Starting import of transmission: .+9712_S1_20180505_lot02.zip/)
      subject
    end

    context 'when import is successful' do
      it { is_expected.to be_success }

      it 'calls Import operation with success' do
        expect(TribunalInstance::Stock::Unit::Operation::Import)
          .to receive(:call)
          .and_return(trb_result_success)
          .once

        subject
      end

      it 'deletes extract directory' do
        directory = Pathname(subject[:dest_directory])
        expect(directory).not_to exist
      end
    end

    context 'when Import fails' do
      before do
        allow(TribunalInstance::Stock::Unit::Operation::Import)
          .to receive(:call)
          .and_return(trb_result_failure)
      end

      it { is_expected.to be_failure }

      it 'deletes extract directory' do
        directory = Pathname(subject[:dest_directory])
        expect(directory).not_to exist
      end
    end
  end

  context 'when ZIP contains multiple files' do
    let(:filename) { 'two_files.zip' }

    before do
      allow(TribunalInstance::Stock::Unit::Operation::Import)
        .to receive(:call)
        .and_return(trb_result_success)
    end

    it { is_expected.to be_success }

    it 'calls Import twice with success' do
      expect_import_success_with 'file_one.xml'
      expect_import_success_with 'file_two.xml'

      subject
    end

    it 'calls Import exactly twice' do
      expect(TribunalInstance::Stock::Unit::Operation::Import)
        .to receive(:call)
        .and_return(trb_result_success)
        .twice

      subject
    end

    def expect_import_success_with(filename)
      expect(TribunalInstance::Stock::Unit::Operation::Import)
        .to receive(:call)
        .with(path: a_string_ending_with(filename), code_greffe: '9712', logger: logger)
        .and_return(trb_result_success)
    end
  end

  context 'when ZIP::Operation::Extract fails' do
    let(:filename) { 'invalid_zip_file.zip' }

    it { is_expected.to be_failure }

    it 'does not call the import operation' do
      expect(TribunalInstance::Stock::Unit::Operation::Import)
        .not_to receive(:call)

      subject
    end

    it 'logs an error' do
      expect(logger)
        .to receive(:error)
        .with /.+this file is not\n  a zipfile.+/
      subject
    end
  end

  context 'MD5 check fails' do
    let(:filename) { 'file_without_md5.zip' }

    it { is_expected.to be_failure }

    it 'does not call the import operation' do
      expect(TribunalInstance::Stock::Unit::Operation::Import)
        .not_to receive(:call)

      subject
    end

    it 'logs an error' do
      expect(logger)
        .to receive(:error)
        .with "MD5 file not found (#{spec_path})"
      subject
    end
  end
end
