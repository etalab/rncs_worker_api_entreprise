require 'rails_helper'

describe Files::Operation::CheckMD5 do
  subject { described_class.call(path: path, logger: logger) }

  let(:logger) { instance_double(Logger).as_null_object }

  describe 'valid MD5' do
    let(:path) { File.join('spec', 'concepts', 'files', 'file_with_valid_md5.txt') }

    it { is_expected.to be_success }

    it 'logs an success' do
      expect(logger).to receive(:info).with("MD5 check success (#{path})")
      subject
    end
  end

  describe 'file to check not found' do
    let(:path) { File.join('spec', 'concepts', 'files', 'missing_file.txt') }

    it { is_expected.to be_failure }

    it 'logs an error' do
      expect(logger).to receive(:error).with("File not found (#{path})")
      subject
    end
  end

  describe 'MD5 file not found' do
    let(:path) { File.join('spec', 'concepts', 'files', 'file_without_md5.txt') }

    it { is_expected.to be_failure }

    it 'logs an error' do
      expect(logger).to receive(:error).with("MD5 file not found (#{path})")
      subject
    end
  end

  describe 'invalid MD5' do
    let(:path) { File.join('spec', 'concepts', 'files', 'file_with_invalid_md5.txt') }

    it { is_expected.to be_failure }

    it 'logs an error' do
      expect(logger).to receive(:error).with("MD5 comparison failed (#{path})")
      subject
    end
  end
end
