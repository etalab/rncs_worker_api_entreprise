require 'rails_helper'

describe SyncFTPJob do
  subject { described_class.perform_now }

  describe 'when all command are successful' do
    before do
      allow_lftp_success
      allow_chmod_success
    end

    it 'calls the commands lines ordered' do
      expect(Open3).to receive(:capture3).with(/lftp/).ordered
      expect(Open3).to receive(:capture3).with(/chmod/).twice.ordered
      subject
    end

    it 'does not log any error' do
      expect(Rails.logger).not_to receive(:error)
      subject
    end
  end

  describe 'when lftp fails' do
    before do
      allow(Open3).to receive(:capture3).with(/lftp/).and_return(['', 'random error', status_failure])
      allow_chmod_success
    end

    it 'logs an error' do
      expect(Rails.logger).to receive(:error).with('LFTP sync failed with: random error')
      subject
    end
  end

  describe 'when chmod fails' do
    before do
      allow_lftp_success
      allow(Open3).to receive(:capture3).with(/chmod/).and_return(['', 'random error', status_failure])
    end

    it 'logs an error' do
      expect(Rails.logger).to receive(:error).with(/Ensure permissions for .+/).twice
      subject
    end
  end

  private

  def allow_chmod_success
      allow(Open3).to receive(:capture3).with(/chmod/).and_call_original
  end

  def allow_lftp_success
      allow(Open3).to receive(:capture3).with(/lftp.+/).and_return(['', '', status_success])
  end

  def status_success
    instance_double Process::Status, success?: true
  end

  def status_failure
    instance_double Process::Status, success?: false
  end
end
