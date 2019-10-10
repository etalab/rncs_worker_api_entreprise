require 'rails_helper'

describe TribunalInstance::Stock::Unit::Operation::Load, :trb do
  subject { described_class.call(logger: logger, stock_unit: stock_unit) }

  let(:stock_unit) { create :stock_unit_titmc, stock: create(:stock_titmc) }
  let(:logger) { instance_double(Logger).as_null_object }

  it 'logs info: import starts' do
    expect(logger).to receive(:info).with(/Starting import of stock \d{4}-\d{2}-\d{2}/)
    subject
  end

  describe 'success' do
    before do
      allow(TribunalInstance::Stock::Unit::Operation::LoadTransmission)
        .to receive(:call)
        .and_return(trb_result_success)
    end

    it { is_expected.to be_success }

    it 'loads transmissions ordered by lot' do
      expect_ordered_import_of_transmissions

      subject
    end
  end

  describe 'when at least one transmission import fails' do
    before do
      allow(TribunalInstance::Stock::Unit::Operation::LoadTransmission)
        .to receive(:call)
        .and_return(trb_result_failure_with(path: '/failed_transmission', error: 'this is an error'))
    end

    it { is_expected.to be_failure }

    it 'does not import the following transmissions' do
      expect(TribunalInstance::Stock::Unit::Operation::LoadTransmission)
        .to receive(:call)
        .once

      subject
    end

    it 'logs an error' do
      expect(logger).to receive(:error).with('Transmission failed (file: /failed_transmission, error: this is an error)')
      subject
    end
  end

  context 'when ResetDatabase fails' do
    it 'is a failure'
  end

  describe 'Success', integration: true do
    let(:stock_unit) { create :stock_unit_titmc_with_valid_zip }

    it { is_expected.to be_success }

    it 'persists two dossiers entreprises' do
      expect { subject }.to change(DossierEntreprise, :count).by(2)
    end

    it 'does not log any error' do
      expect(logger).not_to(receive(:error))
      subject
    end
  end

  def expect_ordered_import_of_transmissions
    (1..2).each do |lot_number|
      expect(TribunalInstance::Stock::Unit::Operation::LoadTransmission)
        .to receive(:call)
        .with(path: a_string_ending_with("lot0#{lot_number}.zip"), code_greffe: '9721', logger: logger)
        .and_return(trb_result_success)
        .ordered
    end
  end
end
