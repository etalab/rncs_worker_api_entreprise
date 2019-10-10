require 'rails_helper'

describe TribunalCommerce::Stock::Operation::PostImport do
  subject { described_class.call(stock_unit: stock_unit) }
  let(:stock_unit) { stock.stock_units.sample }

  context 'when stock import not completed' do
    let(:stock) { create :stock_with_one_error_unit }

    it { is_expected.to be_failure }
  end

  context 'when stock import is completed' do
    let(:stock) { create :stock_with_completed_units }

    it { is_expected.to be_success }
    it 'create db indexes'
    it 'create foreign key link'
  end
end
