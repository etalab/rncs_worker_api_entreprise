require 'rails_helper'

describe DataSource::Stock::TribunalInstance::Unit::Operation::Load, :trb do
  subject { described_class.call logger: logger, stock_unit: stock_unit }

  let(:stock_unit) { create :stock_unit_wildcard, stock: create(:stock_titmc) }
  let(:logger) { object_double(Rails.logger, info: true).as_null_object }

  context 'logger:' do
    it 'logs' do
      expect(logger).to receive(:info).with /Stock \d{4}-\d{2}-\d{2}/
      subject
    end
  end

  describe 'success' do
    before do
      allow(DataSource::Stock::TribunalInstance::Unit::Operation::LoadTransmission)
        .to receive(:call)
        .and_return(trb_result_success)
    end

    it { is_expected.to be_success }

    it 'loads transmissions ordered by lot' do
      (1..2).each do |lot_number|
       expect(DataSource::Stock::TribunalInstance::Unit::Operation::LoadTransmission)
        .to receive(:call)
        .with(path: a_string_ending_with("lot0#{lot_number}.zip"), code_greffe: '9721', logger: logger)
        .and_return(trb_result_success)
        .ordered
      end

      subject
    end
  end

  describe 'failure' do
    before do
      allow(DataSource::Stock::TribunalInstance::Unit::Operation::LoadTransmission)
        .to receive(:call)
        .and_return(trb_result_failure_with(path: '/failed_transmission', error: 'this is an error'))
    end

    it { is_expected.to be_failure }

    it 'calls LoadTransmission only once' do
      expect(DataSource::Stock::TribunalInstance::Unit::Operation::LoadTransmission)
        .to receive(:call)
        .once

      subject
    end

    it 'logs an error' do
      expect(logger).to receive(:error).with 'Transmission failed (file: /failed_transmission, error: this is an error)'
      subject
    end
  end

  context 'when ResetDatabase fails' do
    it 'is a failure'
  end

  describe '[integration] Success' do
    let(:stock_unit) { create :stock_unit_titmc_with_valid_zip }

    it { is_expected.to be_success }

    it 'does not log any error' do
      expect(logger).not_to receive(:error)
      subject
    end
  end
end
