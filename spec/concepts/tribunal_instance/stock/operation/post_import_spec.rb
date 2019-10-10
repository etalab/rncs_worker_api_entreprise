require 'rails_helper'

describe TribunalInstance::Stock::Operation::PostImport do
  subject { described_class.call(stock_unit: stock_unit, logger: logger) }

  let(:logger) { instance_double(Logger).as_null_object }
  let(:stock_unit) { stock.stock_units.sample }

  context 'when stock import not completed' do
    let(:stock) { create :stock_with_one_error_unit }

    it { is_expected.to be_failure }

    it 'logs a warnning' do
      expect(logger).to receive(:warn).with('Import not completed, skipping index creation')
      subject
    end
  end

  context 'when stock import is completed' do
    let(:stock) { create :stock_with_completed_units }

    it { is_expected.to be_success }
    it 'create db indexes'
    it 'logs success' do
      expect(logger).to receive(:info).with('TITMC indexes created')
      subject
    end
  end
end
