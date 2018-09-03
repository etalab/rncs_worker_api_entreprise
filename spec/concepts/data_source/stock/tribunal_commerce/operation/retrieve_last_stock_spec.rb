require 'rails_helper'

describe DataSource::Stock::TribunalCommerce::Operation::RetrieveLastStock do
  context 'when no valid stocks are found' do
    # Override class dependency for specs purposes
    subject { described_class.call(stocks_folder: source_path)}

    context 'when no stocks are found in sources directory' do
      let(:source_path) { Rails.root.join('spec', 'data_source_example', 'no_stock_here') }

      it 'is failure' do
        expect(subject).to be_failure
      end

      it 'sets an error message' do
        msg = "No stock found inside #{source_path}. Ensure the folder exists with a valid subfolder structure."

        expect(subject[:error]).to eq(msg)
      end
    end

    context 'when folder structure for stocks is unexpected' do
      let(:source_path) { Rails.root.join('spec', 'data_source_example', 'invalid_stock_structure') }

      it 'is failure' do
        expect(subject).to be_failure
      end

      it 'sets an error message' do
        msg = "No stock found inside #{source_path}. Ensure the folder exists with a valid subfolder structure."

        expect(subject[:error]).to eq(msg)
      end
    end
  end

  # Inside the stocks folder, stocks are packaged inside a AAAA/MM/DD subfolder structures
  context 'when stocks are found' do
    subject { described_class.call }

    it 'fetch the stock_folder path from the configuration' do
      stock_folder_path = File.join(Rails.configuration.rncs_sources['path'], 'tc', 'stock')

      expect(subject[:stocks_folder]).to eq stock_folder_path
    end

    it 'is success' do
      expect(subject).to be_success
    end

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
