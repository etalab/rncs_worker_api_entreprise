require 'rails_helper'

describe DataSource::Stock::TribunalCommerce::Unit::Operation::OrderFiles do
  let(:params) do
    [
      { random_key: 'random data', run_order: 4 },
      { random_key: 'random data', run_order: 9 },
      { random_key: 'random data', run_order: 1 },
      { random_key: 'random data', run_order: 8 },
    ]
  end

  let(:task_container) do
    Class.new(Trailblazer::Operation) do
      step DataSource::Stock::TribunalCommerce::Unit::Operation::OrderFiles
    end
  end

  subject { task_container.call(stock_files: params) }

  context 'when :run_order is present in hash params' do
    it { is_expected.to be_success }

    it 'orders by :run_order' do
      result = subject[:stock_files]
      ordered_list = [
        { random_key: 'random data', run_order: 1 },
        { random_key: 'random data', run_order: 4 },
        { random_key: 'random data', run_order: 8 },
        { random_key: 'random data', run_order: 9 }
      ]

      expect(result).to eq(ordered_list)
    end
  end

  context 'when :run_order is absent' do
    let(:params) { [{ no_order: '' }] }

    it { is_expected.to be_failure }
  end
end
