require 'rails_helper'

describe DataSource::Stock::TribunalCommerce::Operation::RetrieveLastStock do
  context 'when no valid stocks are found' do
    # Override class dependency for specs purposes
    subject { described_class.call(stocks_folder: source_path)}

    context 'when no stocks are found in sources directory' do
      let(:source_path) { Rails.root.join('spec', 'data_source_example', 'no_stock_here') }

      it { is_expected.to be_failure }
      its([:error]) { is_expected.to eq("No stock found inside #{source_path}. Ensure the folder exists with a valid subfolder structure.") }
    end

    context 'when folder structure for stocks is unexpected' do
      let(:source_path) { Rails.root.join('spec', 'data_source_example', 'invalid_stock_structure') }

      it { is_expected.to be_failure }
      its([:error]) { is_expected.to eq("No stock found inside #{source_path}. Ensure the folder exists with a valid subfolder structure.") }
    end
  end

  # Inside the stocks folder, stocks are packaged inside a AAAA/MM/DD subfolder structures
  context 'when stocks are found' do
    subject { described_class.call }

    stock_folder_path = File.join(Rails.configuration.rncs_sources['path'], 'tc', 'stock')

    its([:stocks_folder]) { is_expected.to eq stock_folder_path }
    it { is_expected.to be_success }

    describe 'returned stock' do
      let(:stock) { subject[:stock] }

      it 'is an instance of StockTribunalCommerce' do
        expect(stock).to be_an_instance_of(StockTribunalCommerce)
      end

      it 'is not saved into database' do
        expect(stock).to_not be_persisted
      end

      # There are three available stocks for specs inside specs/data_source_example/tc/stock :
      # ['2016/08/23', '2017/01/02', '2017/05/04']
      it 'is the latest available' do
        stock_date = [stock.year, stock.month, stock.day].join('/')

        expect(stock_date).to eq('2017/05/04')
      end
    end
  end
end
