require 'rails_helper'

describe TribunalCommerce::DailyUpdate::Operation::FetchPartialStocksInPipe do
  context 'when no partial stocks are found' do
    let(:source_path) { Rails.root.join('spec', 'fixtures', 'tc', 'no_stock_here', 'got_you') }
    subject { described_class.call(partial_stock_folder: source_path) }

    it { is_expected.to be_success }

    it 'returns an empty list' do
      partial_stocks = subject[:partial_stocks]

      expect(partial_stocks).to be_empty
    end
  end

  # spec/fixtures/tc/stock
  # ├── 2016
  # │   └── 09
  # │       └── 28
  # ├── 2017
  # │   ├── 01
  # │   │   └── 28
  # │   └── 11
  # │       └── 08
  # └── 2018
  #     └── 04
  #         └── 12
  context 'when partials stocks are found' do
    let(:source_path) { Rails.root.join('spec', 'fixtures', 'tc', 'stock') }
    subject { described_class.call(partial_stock_folder: source_path) }

    it { is_expected.to be_success }

    it 'returns all partial stocks as records' do
      updates = subject[:partial_stocks]

      expect(updates).to all(be_an_instance_of(DailyUpdateTribunalCommerce))
      expect(updates).to all(have_attributes(partial_stock?: true))
      expect(updates.size).to eq(4)
    end

    it 'matches the dates found in repository'

    it 'ignores complete stocks'
  end
end
